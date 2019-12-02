import std.range.primitives;
import std.algorithm;

int fuelTotal(alias fuel, R)(R masses)
	if (isInputRange!R)
{
	return masses.map!fuel.sum;
}

unittest {
	static import one;

	int[] exampleMasses = [12, 14, 1969, 100756];
	assert(fuelTotal!(one.fuel)(exampleMasses) == 2 + 2 + 654 + 33583);
}

unittest {
	static import two;

	int[] exampleMasses = [14, 1969, 100756];
	assert(fuelTotal!(two.fuel)(exampleMasses) == 2 + 966 + 50346);
}
