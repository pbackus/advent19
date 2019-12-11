import asteroid;
import util;

import std.algorithm;
import std.range;
import std.stdio;
import std.typecons;

bool[][] readMap(File input)
{
	import std.conv;

	return input.byLine.parseMap;
}

void partOne()
{
	bool[][] map = stdin.readMap;

	map.points
		.map!(p => tuple(p, p.visibleAsteroids(map)))
		.maxElement!(unpack!((p, n) => n))
		.unpack!((p, n) { writefln("(%d, %d): %d", p.x, p.y, n); });
}

void partTwo()
{
	return;
}

void main(string[] args)
{
	import std.format;
	import std.getopt;

	int part = 1;

	auto options = args.getopt(
		"part|p", "Part of the problem to solve (default: 1)", &part
	);

	if (options.helpWanted) {
		defaultGetoptPrinter(
			format("Usage: %s [-h] [-p N]", args[0]),
			options.options
		);
		return;
	}

	if (part == 1) {
		partOne;
	} else if (part == 2) {
		partTwo;
	}
}


