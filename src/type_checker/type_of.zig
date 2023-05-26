const types = @import("types.zig");
const Expression = types.Expression;
const MonoType = types.MonoType;

pub fn typeOf(e: Expression) MonoType {
    return switch (e) {
        .int => |i| i.type,
        .float => |f| f.type,
        .symbol => |s| s.type,
        .bool => |b| b.type,
        .string => |s| s.type,
        .define => |d| d.type,
        .function => |f| f.type,
        .binary_op => |b| b.type,
        .group => |g| g.type,
        .block => |b| b.type,
        .if_else => |i| i.type,
        .cond => |c| c.type,
        .call => |c| c.type,
        .intrinsic => |i| i.type,
        .foreign_import => |f| f.type,
        .convert => |c| c.type,
    };
}