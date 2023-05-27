const std = @import("std");
const neuron = @import("neuron");

test "type infer sqrt f32" {
    const allocator = std.testing.allocator;
    const source =
        \\start = fn(x: f32) f32 {
        \\    sqrt(x)
        \\}
    ;
    const actual = try neuron.testing.typeInfer(allocator, source, "start");
    defer allocator.free(actual);
    const expected =
        \\define =
        \\    name = symbol{ name = start, type = fn(f32) f32 }
        \\    type = void
        \\    value = 
        \\        function =
        \\            parameters =
        \\                symbol{ name = x, type = f32 }
        \\            return_type = f32
        \\            body = 
        \\                intrinsic =
        \\                    sqrt
        \\                    arguments =
        \\                        symbol{ name = x, type = f32 }
        \\                    type = f32
    ;
    try std.testing.expectEqualStrings(expected, actual);
}

test "codegen sqrt f32" {
    const allocator = std.testing.allocator;
    const source =
        \\start = fn(x: f32) f32 {
        \\    sqrt(x)
        \\}
    ;
    const actual = try neuron.testing.codegen(allocator, source);
    defer allocator.free(actual);
    const expected =
        \\(module
        \\
        \\    (func $start (param $x f32) (result f32)
        \\        (f32.sqrt
        \\            (local.get $x)))
        \\
        \\    (export "_start" (func $start)))
    ;
    try std.testing.expectEqualStrings(expected, actual);
}
