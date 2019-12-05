import util;
import password;

import std.algorithm;
import std.array;
import std.range;
import std.typecons;

bool isStrictlyValid(int[6] digits)
{
	bool isIsolatedPair(size_t i, size_t j) const
	{
		return digits[i] == digits[j]
			&& (i == 0 || digits[i - 1] != digits[i])
			&& (j >= 5 || digits[j + 1] != digits[j]);
	}

	alias Result = Tuple!(bool, "hasIsolatedPair", bool, "increasing");

	return digits[]
		.enumerate
		.slide(2)
		.map!(pair => pair.staticArray!2)
		.fold!((soFar, pair) =>
			Result(
				soFar.hasIsolatedPair
					|| isIsolatedPair(pair[0].index, pair[1].index),
				soFar.increasing && pair[0].value <= pair[1].value
			)
		)(Result(false, true))
		.unpack!((hasPair, increasing) =>
			hasPair && increasing
		);
}

unittest {
	assert( [1, 1, 2, 2, 3, 3].isStrictlyValid);
	assert(![1, 2, 3, 4, 4, 4].isStrictlyValid);
	assert( [1, 1, 1, 1, 2, 2].isStrictlyValid);
}

int[6] nextStrict(int[6] password)
{
	do {
		password.increment;
		password.removeDecrease;
	} while (!password.isStrictlyValid);

	return password;
}

struct StrictPassword
{
	private int[6] digits_;

	invariant(digits_[].all!isDigit);
	invariant(digits_.isStrictlyValid);

	static StrictPassword above(int[6] digits)
	{
		return StrictPassword(
			digits.isStrictlyValid ? digits : digits.nextStrict
		);
	}

	int[6] digits() const
	{
		return digits_;
	}

	StrictPassword next() const
	{
		return StrictPassword(digits_.nextStrict);
	}
}

