const std = @import("std");
const List = std.ArrayList;
const Writer = List(u8).Writer;

const types = @import("types.zig");

const Indent = u64;

fn newlineAndIndent(indent: Indent, writer: Writer) !void {
    if (indent > 0) try writer.writeAll("\n");
    for (0..indent) |_| try writer.writeAll("    ");
}

pub fn define(d: types.Define, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(def ");
    if (d.mutable) try writer.writeAll("mut ");
    try writer.print("{}", .{d.name.value});
    if (d.type) |t| {
        try writer.writeAll(" ");
        try expression(t.*, indent, writer);
    }
    try writer.writeAll(" ");
    try expression(d.value.*, indent + 1, writer);
    try writer.writeAll(")");
}

pub fn drop(d: types.Drop, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(drop ");
    try expression(d.value.*, indent + 1, writer);
    try writer.writeAll(")");
}

pub fn plusEqual(p: types.PlusEqual, indent: Indent, writer: Writer) !void {
    try writer.print("(+= {} ", .{p.name.value});
    try expression(p.value.*, indent + 1, writer);
    try writer.writeAll(")");
}

pub fn timesEqual(t: types.TimesEqual, indent: Indent, writer: Writer) !void {
    try writer.print("(*= {} ", .{t.name.value});
    try expression(t.value.*, indent + 1, writer);
    try writer.writeAll(")");
}

pub fn function(f: types.Function, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(fn [");
    for (f.parameters, 0..) |param, j| {
        if (j > 0) try writer.writeAll(" ");
        try writer.writeAll("(");
        if (param.mutable) try writer.writeAll("mut ");
        try writer.print("{} ", .{param.name.value});
        try expression(param.type, indent, writer);
        try writer.writeAll(")");
    }
    try writer.writeAll("] ");
    try expression(f.return_type.*, indent, writer);
    try block(f.body, indent, writer);
    try writer.writeAll(")");
}

pub fn prototype(p: types.Prototype, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(fn [");
    for (p.parameters, 0..) |param, j| {
        if (j > 0) try writer.writeAll(" ");
        try writer.print("({} ", .{param.name.value});
        try expression(param.type, indent, writer);
        try writer.writeAll(")");
    }
    try writer.writeAll("] ");
    try expression(p.return_type.*, indent, writer);
    try writer.writeAll(")");
}

pub fn enumeration(e: types.Enumeration, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(enum");
    for (e.variants) |variant| {
        try newlineAndIndent(indent, writer);
        try writer.writeAll(variant.value.string());
    }
    try writer.writeAll(")");
}

pub fn structure(s: types.Structure, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(struct");
    for (s.order) |interned| {
        const field = s.fields.get(interned).?;
        try newlineAndIndent(indent, writer);
        try writer.print("{s} ", .{field.name.value.string()});
        try expression(field.type, indent, writer);
    }
    try writer.writeAll(")");
}

pub fn structLiteral(s: types.StructLiteral, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(struct_literal");
    for (s.order) |interned| {
        const field = s.fields.get(interned).?;
        try newlineAndIndent(indent, writer);
        try writer.print("{s} ", .{field.name.value.string()});
        try expression(field.value, indent, writer);
    }
    try writer.writeAll(")");
}

pub fn binaryOp(b: types.BinaryOp, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(");
    switch (b.kind) {
        .add => try writer.writeAll("+"),
        .subtract => try writer.writeAll("-"),
        .multiply => try writer.writeAll("*"),
        .divide => try writer.writeAll("/"),
        .modulo => try writer.writeAll("%"),
        .exponentiate => try writer.writeAll("^"),
        .equal => try writer.writeAll("=="),
        .greater => try writer.writeAll(">"),
        .less => try writer.writeAll("<"),
        .or_ => try writer.writeAll("or"),
        .dot => try writer.writeAll("."),
        .pipeline => try writer.writeAll("|>"),
    }
    try writer.writeAll(" ");
    try expression(b.left.*, indent, writer);
    try writer.writeAll(" ");
    try expression(b.right.*, indent, writer);
    try writer.writeAll(")");
}

pub fn block(b: types.Block, indent: Indent, writer: Writer) !void {
    try newlineAndIndent(indent, writer);
    if (b.expressions.len == 1) {
        return try expression(b.expressions[0], indent + 1, writer);
    }
    try writer.writeAll("(block");
    for (b.expressions) |expr| {
        try newlineAndIndent(indent + 1, writer);
        try expression(expr, indent + 1, writer);
    }
    try writer.writeAll(")");
}

pub fn array(a: types.Array, indent: Indent, writer: Writer) !void {
    try newlineAndIndent(indent, writer);
    for (a.expressions) |expr| {
        try newlineAndIndent(indent + 1, writer);
        try expression(expr, indent + 1, writer);
    }
    try writer.writeAll("]");
}

pub fn arrayOf(a: types.ArrayOf, indent: Indent, writer: Writer) !void {
    if (a.size) |size| {
        try writer.print("[{}]", .{size.value});
    } else {
        try writer.writeAll("[]");
    }
    try expression(a.element_type.*, indent, writer);
}

pub fn branch(b: types.Branch, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(branch");
    for (b.arms) |arm| {
        try newlineAndIndent(indent, writer);
        try expression(arm.condition, indent, writer);
        try block(arm.then, indent + 1, writer);
    }
    try newlineAndIndent(indent, writer);
    try writer.writeAll("else");
    try block(b.else_, indent + 1, writer);
    try writer.writeAll(")");
}

pub fn call(c: types.Call, indent: Indent, writer: Writer) !void {
    try writer.writeAll("(");
    try expression(c.function.*, indent, writer);
    for (c.arguments) |a| {
        try writer.writeAll(" ");
        if (a.mutable) {
            try writer.writeAll("(mut ");
            try expression(a.value, indent + 1, writer);
            try writer.writeAll(")");
        } else {
            try expression(a.value, indent + 1, writer);
        }
    }
    try writer.writeAll(")");
}

pub fn expression(e: types.Expression, indent: Indent, writer: Writer) error{OutOfMemory}!void {
    switch (e) {
        .int => |int| try writer.print("{}", .{int.value}),
        .float => |f| try writer.print("{}", .{f.value}),
        .symbol => |s| try writer.print("{}", .{s.value}),
        .string => |s| try writer.print("{}", .{s.value}),
        .bool => |b| try writer.print("{}", .{b.value}),
        .define => |d| try define(d, indent, writer),
        .drop => |d| try drop(d, indent, writer),
        .plus_equal => |p| try plusEqual(p, indent, writer),
        .times_equal => |t| try timesEqual(t, indent, writer),
        .function => |f| try function(f, indent, writer),
        .prototype => |p| try prototype(p, indent, writer),
        .enumeration => |en| try enumeration(en, indent, writer),
        .structure => |s| try structure(s, indent, writer),
        .struct_literal => |s| try structLiteral(s, indent, writer),
        .binary_op => |b| try binaryOp(b, indent, writer),
        .group => |g| try expression(g.expression.*, indent, writer),
        .block => |b| try block(b, indent, writer),
        .array => |a| try array(a, indent, writer),
        .branch => |b| try branch(b, indent, writer),
        .call => |c| try call(c, indent, writer),
        .undefined => |u| try writer.print("{}", .{u}),
    }
}

pub fn topLevelForeignImport(f: types.TopLevelForeignImport, indent: Indent, writer: Writer) !void {
    try writer.print("(def {s}", .{f.name.value.string()});
    if (f.type) |t| {
        try writer.writeAll(" ");
        try expression(t.*, indent, writer);
    }
    try writer.writeAll(" ");
    try call(f.call, indent + 1, writer);
    try writer.writeAll(")");
}

pub fn topLevelStructure(s: types.TopLevelStructure, indent: Indent, writer: Writer) !void {
    try writer.print("(def {s}", .{s.name.value.string()});
    if (s.type) |t| {
        try writer.writeAll(" ");
        try expression(t.*, indent, writer);
    }
    try writer.writeAll(" ");
    try structure(s.structure, indent + 1, writer);
    try writer.writeAll(")");
}

pub fn topLevelEnumeration(e: types.TopLevelEnumeration, indent: Indent, writer: Writer) !void {
    try writer.print("(def {s}", .{e.name.value.string()});
    if (e.type) |t| {
        try writer.writeAll(" ");
        try expression(t.*, indent, writer);
    }
    try writer.writeAll(" ");
    try enumeration(e.enumeration, indent + 1, writer);
    try writer.writeAll(")");
}

pub fn topLevelFunction(f: types.TopLevelFunction, indent: Indent, writer: Writer) !void {
    try writer.print("(def {s}", .{f.name.value.string()});
    if (f.type) |t| {
        try writer.writeAll(" ");
        try expression(t.*, indent, writer);
    }
    try writer.writeAll(" ");
    try function(f.function, indent + 1, writer);
    try writer.writeAll(")");
}

pub fn module(m: types.Module, writer: Writer) !void {
    var i: usize = 0;
    for (m.foreign_imports) |f| {
        if (i > 0) try writer.writeAll("\n\n");
        try topLevelForeignImport(f, 0, writer);
        i += 1;
    }
    for (m.structures) |s| {
        if (i > 0) try writer.writeAll("\n\n");
        try topLevelStructure(s, 0, writer);
        i += 1;
    }
    for (m.enumerations) |e| {
        if (i > 0) try writer.writeAll("\n\n");
        try topLevelEnumeration(e, 0, writer);
        i += 1;
    }
    for (m.functions) |f| {
        if (i > 0) try writer.writeAll("\n\n");
        try topLevelFunction(f, 0, writer);
        i += 1;
    }
    for (m.defines) |d| {
        if (i > 0) try writer.writeAll("\n\n");
        try define(d, 0, writer);
        i += 1;
    }
    for (m.foreign_exports) |f| {
        if (i > 0) try writer.writeAll("\n\n");
        try call(f, 0, writer);
        i += 1;
    }
    for (m.ignored) |ig| {
        if (i > 0) try writer.writeAll("\n\n");
        try expression(ig, 0, writer);
        i += 1;
    }
}
