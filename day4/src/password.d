import util;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.range;
import std.typecons;

bool isDigit(int n)
{
	return n >= 0 && n < 10;
}

unittest {
	foreach (i; 0 .. 10) {
		assert(i.isDigit);
	}

	assert(!10.isDigit);
	assert(!(-1).isDigit);
}

bool isValid(const(int)[] password)
{
	alias Result = Tuple!(bool, "hasPair", bool, "increasing");

	return password[]
		.slide(2)
		.map!(pair => pair.staticArray!2)
		.fold!((soFar, digits) =>
			Result(
				soFar.hasPair || digits[0] == digits[1],
				soFar.increasing && digits[0] <= digits[1]
			)
		)(Result(false, true))
		.unpack!((hasPair, increasing) =>
			hasPair && increasing
		);
}

unittest {
	assert( isValid([1, 1, 1, 1, 1, 1]));
	assert(!isValid([2, 2, 3, 4, 5, 0]));
	assert(!isValid([1, 2, 3, 7, 8, 9]));
}

struct Password
{
	private int[6] digits_;

	invariant(digits_[].all!isDigit);
	invariant(isValid(digits_[]));

	this(int[] digits)
		in (digits.length == 6)
	{
		digits_[] = digits[];
		skipInvalid;
	}

	private void skipInvalid()
	{
		digits_[]
			.enumerate
			.slide(2)
			.map!(pair => pair.staticArray!2)
			.find!(pair => pair[0].value > pair[1].value)
			.take(1)
			.each!((decreasingPair) {
				decreasingPair[0].unpack!((index, value) {
					digits_[index .. $] = value;
				});
			});
	}

	int[6] digits()
	{
		return digits_;
	}

	Password opUnary(string op : "++")()
	{
		int carry = 1;

		digits_[]
			.retro
			.each!((ref digit) {
				digit += carry;
				carry = digit / 10;
				digit = digit % 10;
				return (carry != 0).to!(Flag!"each");
			});

		skipInvalid;
		return this;
	}
}

unittest {
	assert(Password([2, 2, 3, 4, 5, 0]).digits == [2, 2, 3, 4, 5, 5]);
}

unittest {
	assert((++Password([1, 1, 2, 3, 4, 5])).digits == [1, 1, 2, 3, 4, 6]);
	assert((++Password([1, 1, 2, 3, 9, 9])).digits == [1, 1, 2, 4, 4, 4]);
}
