const std = @import("std");
const List = std.ArrayList;
const Allocator = std.mem.Allocator;

const Interned = @import("../interner.zig").Interned;
const type_checker = @import("../type_checker.zig");

pub const UndefinedVariable = struct {
    symbol: Interned,
    span: type_checker.types.Span,
    in_scope: []const Interned,
};

pub const TypeMismatch = struct {
    left: type_checker.monotype.MonoType,
    right: type_checker.monotype.MonoType,
};

pub const MutabilityAndSpan = struct {
    mutable: bool,
    span: ?type_checker.types.Span,
};

pub const MutabilityMismatch = struct {
    left: MutabilityAndSpan,
    right: MutabilityAndSpan,
};

pub const ReassigningImmutable = struct {
    span: type_checker.types.Span,
    name: Interned,
};

pub const Errors = struct {
    allocator: Allocator,
    undefined_variable: List(UndefinedVariable),
    type_mismatch: List(TypeMismatch),
    mutability_mismatch: List(MutabilityMismatch),
    reassigning_immutable: List(ReassigningImmutable),
    source: []const u8,
};
