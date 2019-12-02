import std.range.primitives;
import std.algorithm;

int fuelTotal(alias fuel, R)(R masses)
	if (isInputRange!R)
{
	return masses.map!fuel.sum;
}

unittest {
	static import first;

	int[] exampleMasses = [12, 14, 1969, 100756];
	assert(fuelTotal!(first.fuel)(exampleMasses) == 2 + 2 + 654 + 33583);
}

unittest {
	static import second;

	int[] exampleMasses = [14, 1969, 100756];
	assert(fuelTotal!(second.fuel)(exampleMasses) == 2 + 966 + 50346);
}
