import std.range.primitives;
import std.algorithm;

int fuel(int mass)
{
	return max(0, (mass / 3) - 2);
}

unittest {
	assert(fuel(12) == 2);
	assert(fuel(14) == 2);
	assert(fuel(1969) == 654);
	assert(fuel(100756) == 33583);
}
