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

int fuelTotal(R)(R masses)
	if (isInputRange!R)
{
	return masses.map!fuel.sum;
}

unittest {
	int[] exampleMasses = [12, 14, 1969, 100756];
	assert(fuelTotal(exampleMasses) == 2 + 2 + 654 + 33583);
}
