const std = @import("std");
const Allocator = std.mem.Allocator;

const types = @import("types.zig");
const Substitution = types.Substitution;
const Module = types.Module;
const MonoType = types.MonoType;
const Typed = types.Typed;
const TopLevel = types.TopLevel;
const Function = types.Function;
const Symbol = types.Symbol;
const Expression = types.Expression;

fn monotype(allocator: Allocator, s: Substitution, m: MonoType) !MonoType {
    switch (m) {
        .i32 => return .i32,
        .void => return .void,
        .module => return .module,
        .function => |f| {
            const mapped = try allocator.alloc(MonoType, f.len);
            for (f) |t, i| mapped[i] = try monotype(allocator, s, t);
            return .{ .function = mapped };
        },
        .typevar => |t| {
            if (s.get(t)) |mono| return mono;
            std.debug.panic("\nUnbound type variable {}", .{t});
        },
        else => std.debug.panic("\nUnsupported monotype {}", .{m}),
    }
}

fn symbol(allocator: Allocator, s: Substitution, sym: Symbol) !Symbol {
    return Symbol{
        .value = sym.value,
        .span = sym.span,
        .type = try monotype(allocator, s, sym.type),
    };
}

fn expression(allocator: Allocator, s: Substitution, e: Expression) !Expression {
    switch (e) {
        .symbol => |sym| return .{ .symbol = try symbol(allocator, s, sym) },
        else => std.debug.panic("\nUnsupported expression {}", .{e}),
    }
}

fn block(allocator: Allocator, s: Substitution, exprs: []const Expression) ![]const Expression {
    const expressions = try allocator.alloc(Expression, exprs.len);
    for (exprs) |e, i| expressions[i] = try expression(allocator, s, e);
    return expressions;
}

fn function(allocator: Allocator, s: Substitution, f: Function) !Function {
    const parameters = try allocator.alloc(Symbol, f.parameters.len);
    for (f.parameters) |p, i| parameters[i] = try symbol(allocator, s, p);
    return Function{
        .name = try symbol(allocator, s, f.name),
        .parameters = parameters,
        .return_type = try monotype(allocator, s, f.return_type),
        .body = try block(allocator, s, f.body),
        .span = f.span,
        .type = try monotype(allocator, s, f.type),
    };
}

fn topLevel(allocator: Allocator, s: Substitution, t: TopLevel) !TopLevel {
    switch (t) {
        .function => |f| return .{ .function = try function(allocator, s, f) },
        else => std.debug.panic("\nUnsupported top level {}", .{t}),
    }
}

pub fn apply(allocator: Allocator, s: Substitution, m: Module) !Module {
    var typed = Typed.init(allocator);
    var iterator = m.typed.iterator();
    while (iterator.next()) |entry| {
        if (m.typed.get(entry.key_ptr.*)) |t| {
            const value = try topLevel(allocator, s, t);
            try typed.putNoClobber(entry.key_ptr.*, value);
        }
    }
    return Module{
        .order = m.order,
        .untyped = m.untyped,
        .typed = typed,
        .scope = m.scope,
        .span = m.span,
        .type = try monotype(allocator, s, m.type),
    };
}