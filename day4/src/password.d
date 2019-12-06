import util;

import std.algorithm;
import std.array;
import std.conv;
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

private alias Result = Tuple!(bool, "hasValidPair", bool, "increasing");

bool equalPair(int[6] digits, size_t i, size_t j)
{
	return digits[i] == digits[j];
}

bool isolatedPair(int[6] digits, size_t i, size_t j)
{
	return digits[i] == digits[j]
		&& (i == 0 || digits[i - 1] != digits[i])
		&& (j >= 5 || digits[j + 1] != digits[j]);
}

bool validWith(alias validPair)(int[6] digits)
{
	return digits[]
		.enumerate
		.slide(2)
		.map!(pair => pair.staticArray!2)
		.fold!((soFar, pair) =>
			Result(
				soFar.hasValidPair
					|| validPair(digits, pair[0].index, pair[1].index),
				soFar.increasing && pair[0] <= pair[1]
			)
		)(Result(false, true))
		.unpack!((hasValidPair, increasing) =>
			hasValidPair && increasing
		);
}

unittest {
	assert( [1, 1, 1, 1, 1, 1].validWith!equalPair);
	assert( [1, 2, 3, 3, 4, 5].validWith!equalPair);
	assert(![1, 2, 3, 4, 5, 0].validWith!equalPair);
	assert(![1, 2, 3, 7, 8, 9].validWith!equalPair);
}

unittest {
	assert( [1, 1, 2, 2, 3, 3].validWith!isolatedPair);
	assert(![1, 2, 3, 4, 4, 4].validWith!isolatedPair);
	assert( [1, 1, 1, 1, 2, 2].validWith!isolatedPair);
}

void removeDecrease(ref int[6] digits)
{
	digits[]
		.enumerate
		.slide(2)
		.map!(pair => pair.staticArray!2)
		.find!(pair => pair[0].value > pair[1].value)
		.take(1)
		.each!((decreasingPair) {
			decreasingPair[0].unpack!((index, value) {
				digits[index .. $] = value;
			});
		});
}

unittest {
	int[6] a1 = [1, 1, 2, 3, 4, 0];
	int[6] a2 = [1, 1, 2, 3, 4, 5];

	a1.removeDecrease;
	a2.removeDecrease;

	assert(a1 == [1, 1, 2, 3, 4, 4]);
	assert(a2 == [1, 1, 2, 3, 4, 5]);
}

void increment(ref int[6] digits)
{
	int carry = 1;

	digits[]
		.retro
		.each!((ref digit) {
			digit += carry;
			carry = digit / 10;
			digit = digit % 10;
			return (carry != 0).to!(Flag!"each");
		});
}

unittest {
	int[6] a1 = [1, 1, 2, 3, 4, 5];
	int[6] a2 = [1, 1, 2, 3, 9, 9];
	int[6] a3 = [9, 9, 9, 9, 9, 9];

	a1.increment;
	a2.increment;
	a3.increment;

	assert(a1 == [1, 1, 2, 3, 4, 6]);
	assert(a2 == [1, 1, 2, 4, 0, 0]);
	assert(a3 == [0, 0, 0, 0, 0, 0]);
}

int[6] next(alias valid)(int[6] password)
{
	
	do {
		password.increment;
		password.removeDecrease;
	} while (!valid(password));

	return password;
}

unittest {
	assert([1, 1, 2, 3, 9, 9].next!(validWith!equalPair)
		== [1, 1, 2, 4, 4, 4]);
	assert([1, 2, 3, 4, 5, 5].next!(validWith!equalPair)
		== [1, 2, 3, 4, 6, 6]);
}

struct Password(Flag!"strict" strict)
{
	static if (strict) {
		alias valid = validWith!isolatedPair;
	} else {
		alias valid = validWith!equalPair;
	}

	private int[6] digits_;

	invariant(digits_[].all!isDigit);
	invariant(valid(digits_));

	static Password above(int[6] digits)
	{
		return Password(
			valid(digits)
				? digits
				: digits.next!valid
		);
	}

	unittest {
		assert(Password.above([2, 4, 8, 3, 4, 5]).digits
			== [2, 4, 8, 8, 8, 8]);
		assert(Password.above([7, 4, 6, 3, 1, 5]).digits
			== [7, 7, 7, 7, 7, 7]);
	}

	int[6] digits() const
	{
		return digits_;
	}

	Password next() const
	{
		return Password(digits_.next!valid);
	}
}
