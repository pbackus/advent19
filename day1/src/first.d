module first;

import std.range.primitives;
import std.algorithm;

int requiredFuel(int mass)
{
	assert(mass >= 6);
	return (mass / 3) - 2;
}

unittest {
	assert(requiredFuel(12) == 2);
	assert(requiredFuel(14) == 2);
	assert(requiredFuel(1969) == 654);
	assert(requiredFuel(100756) == 33583);
}

int totalFuel(R)(R masses)
	if (isInputRange!R)
{
	return masses.map!requiredFuel.sum;
}

unittest {
	int[] exampleMasses = [12, 14, 1969, 100756];
	assert(totalFuel(exampleMasses) == 2 + 2 + 654 + 33583);
}
