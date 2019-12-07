import util;

import std.algorithm;
import std.range;
import std.typecons;

struct SpaceObject
{
	string name;
	SpaceObject*[] satellites;
}

SpaceObject *spaceObject(string name, SpaceObject*[] satellites = null)
{
	return new SpaceObject(name, satellites);
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

unittest {
	SpaceObject* exampleCom =
		spaceObject("COM", [
			spaceObject("B", [
				spaceObject("C", [
					spaceObject("D", [
						spaceObject("E", [
							spaceObject("F"),
							spaceObject("J", [
								spaceObject("K", [
									spaceObject("L")
								])
							])
						]),
						spaceObject("I")
					])
				]),
				spaceObject("G", [
					spaceObject("H")
				])
			])
		]);

	assert(exampleCom.orbitCount == 42);
}

alias System = SpaceObject*[string];

void addObject(ref System system, string name)
{
	system.update(
		name,
		() => new SpaceObject(name),
		(SpaceObject* existing) => existing
	);
}

void addSatellite(ref System system, string name, string satellite)
{
	system.addObject(name);
	system.addObject(satellite);
	system[name].satellites ~= system[satellite];
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

size_t orbitCount(System system)
{
	return system["COM"].orbitCount;
}

unittest {
	System system = system([
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

	assert(system["COM"].satellites[0] == system["B"]);
	assert(system.orbitCount == 42);
}
