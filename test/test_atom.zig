const std = @import("std");
pub const test_binary_ops = @import("test_binary_ops.zig");
pub const test_call = @import("test_call.zig");
pub const test_define = @import("test_define.zig");
pub const test_function = @import("test_function.zig");
pub const test_if = @import("test_if.zig");
pub const test_literals = @import("test_literals.zig");

test "run all tests" {
    std.testing.refAllDecls(@This());
}
