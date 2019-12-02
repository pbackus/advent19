import std.range.primitives;
import std.algorithm;

int fuel(int mass)
{
	static import one;

	if (mass == 0) {
		return 0;
	} else {
		int baseFuel = one.fuel(mass);
		return baseFuel + fuel(baseFuel);
	}
}

unittest {
	assert(fuel(14) == 2);
	assert(fuel(1969) == 966);
	assert(fuel(100756) == 50346);
}
