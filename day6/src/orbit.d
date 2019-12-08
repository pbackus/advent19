import util;

import std.algorithm;
import std.functional;
import std.range;
import std.typecons;

import optional;

struct SpaceObject
{
	string name;
	SpaceObject*[] satellites;
}

size_t orbitsAround(SpaceObject* object)
{
	return object.satellites.length
		+ object.satellites.map!orbitsAround.sum;
}

size_t orbitCount(SpaceObject* center)
{
	return orbitsAround(center)
		+ center.satellites.map!orbitCount.sum;
}

alias System = SpaceObject*[string];

void addObject(ref System sys, string name)
{
	sys.update(
		name,
		() => new SpaceObject(name),
		(SpaceObject* existing) => existing
	);
}

void addSatellite(ref System sys, string name, string satellite)
{
	sys.addObject(name);
	sys.addObject(satellite);
	sys[name].satellites ~= sys[satellite];
}

System system(Map)(Map orbitMap)
	if(isInputRangeOf!(Map, Tuple!(string, string)))
{
	System result;

	orbitMap.each!(unpack!((name, satellite) {
		result.addSatellite(name, satellite);
	}));

	return result;
}

size_t orbitCount(System sys)
{
	return sys["COM"].orbitCount;
}

unittest {
	System sys = system([
		tuple("COM", "B"),
		tuple("B", "C"),
		tuple("C", "D"),
		tuple("D", "E"),
		tuple("E", "F"),
		tuple("B", "G"),
		tuple("G", "H"),
		tuple("D", "I"),
		tuple("E", "J"),
		tuple("J", "K"),
		tuple("K", "L")
	]);

	assert(sys["COM"].satellites[0] == sys["B"]);
	assert(sys.orbitCount == 42);
}

Optional!size_t distanceTo(SpaceObject* start, string end)
{
	Optional!size_t impl()
	{
		if (start.name == end) {
			return some!size_t(0);
		} else if (start.satellites.length == 0) {
			return no!size_t;
		} else {
			return start
				.satellites
				.map!(sat => sat.distanceTo(end) + 1)
				.joiner
				.pipe!(results =>
					results.empty? no!size_t : some(results.front)
				);
		}
	}

	static Optional!size_t[Tuple!(SpaceObject*, string)] memo;

	if (Optional!size_t* result = tuple(start, end) in memo) {
		return *result;
	} else {
		memo[tuple(start, end)] = impl();
		return memo[tuple(start, end)];
	}
}

Optional!size_t distance(System sys, string start, string end)
{
	return sys
		.byValue
		.map!(obj =>
			obj.distanceTo(start).flatMap!(d1 =>
				obj.distanceTo(end).flatMap!(d2 =>
					some(d1 + d2)
				)
			)
		)
		.joiner
		.pipe!(results =>
			results.empty ? no!size_t : some(results.fold!min)
		);

}

unittest {
	System sys = system([
		tuple("COM", "B"),
		tuple("B", "C"),
		tuple("C", "D"),
		tuple("D", "E"),
		tuple("E", "F"),
		tuple("B", "G"),
		tuple("G", "H"),
		tuple("D", "I"),
		tuple("E", "J"),
		tuple("J", "K"),
		tuple("K", "L"),
		tuple("K", "YOU"),
		tuple("I", "SAN")
	]);

	assert(sys.distance("YOU", "SAN") == 6);
	assert(sys.distance("K", "I") == 4);
	assert(sys.distance("COM", "COM") == 0);
	assert(sys.distance("B", "D") == 2);
	assert(sys.distance("D", "B") == 2);
}
