import std.range.primitives;

enum bool isInputRangeOf(R, E) =
	isInputRange!R && is(ElementType!R : E);
