const types = @import("types.zig");

pub fn expression(e: types.Expression) types.MonoType {
    return switch (e) {
        .int => |i| i.type,
        .float => |f| f.type,
        .symbol => |s| s.type,
        .bool => |b| b.type,
        .string => |s| s.type,
        .define => |d| d.type,
        .drop => |d| d.type,
        .plus_equal => |p| p.type,
        .times_equal => |t| t.type,
        .function => |f| f.type,
        .binary_op => |b| b.type,
        .group => |g| g.type,
        .block => |b| b.type,
        .branch => |b| b.type,
        .call => |c| c.type,
        .intrinsic => |i| i.type,
        .foreign_import => |f| f.type,
        .foreign_export => |f| f.type,
        .convert => |c| c.type,
        .undefined => |u| u.type,
        .variant => |v| v.type,
        .struct_literal => |s| s.type,
    };
}
