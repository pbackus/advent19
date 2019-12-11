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
