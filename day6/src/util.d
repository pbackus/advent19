import std.range.primitives;

import optional;

auto ref orElse(T)(auto ref T value, lazy T fallback)
{
	return value ? value : fallback;
}

/** Tuple unpacker
 *
 * Usage: myTuple.unpack!((x, y) => f(x, y));
 *
 * Arguments are bound by order; names are irrelevant.
 *
 * Based on 'tupArg' by Dukc:
 *   https://forum.dlang.org/thread/rkfezigmrvuzkztxqqxy@forum.dlang.org
 */
template unpack(alias fun)
{
	import std.typecons: isTuple;

	auto unpack(T)(T args)
		if (isTuple!T)
	{
		return fun(args.expand);
	}
}

enum bool isInputRangeOf(R, E) =
	isInputRange!R && is(ElementType!R : E);

/// Mondaic bind for Optional
template flatMap(alias fun)
{
	auto flatMap(O)(O opt)
		if (isOptional!O)
	{
		alias T = typeof(opt.front());

		return opt.match!(
			(T value) => fun(value),
			() => O(none)
		);
	}
}
