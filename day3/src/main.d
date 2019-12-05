import util;
import wire;

import std.algorithm;
import std.conv;
import std.format;
import std.functional;
import std.getopt;
import std.math;
import std.range;
import std.stdio;

Wire readWire(const(char)[] line)
{
	return Wire(
		line
		.splitter(',')
		.enumerate
		.map!(unpack!((i, step) => move(
			step[0].to!Direction,
			step[1 .. $].to!int - (i == 0) // skip origin
		)))
		.pipe!((points) =>
			chain(
				only(Point(
					// skip origin
					0 + cast(int) sgn(points.front.x),
					0 + cast(int) sgn(points.front.y)
				)),
				points
			)
		)
		.cumulativeFold!((pos, move) => pos + move)(origin)
		.slide(2)
		.map!array
		.map!(pair => Segment(pair[0], pair[1]))
		.array
	);
}

Wire[] readWires(File input)
{
	return input
		.byLine
		.map!readWire
		.array;
}

void partOne()
{
	Wire[] wires = stdin.readWires;

	assert(wires.length == 2, "Part 1 solution requires exactly 2 wires.");

	intersections(wires[0], wires[1])
		.map!distance
		.fold!min
		.writeln;
}

void partTwo()
{
	Wire[] wires = stdin.readWires;

	assert(wires.length == 2, "Part 2 solution requires exactly 2 wires");

	intersections(wires[0], wires[1])
		.map!(p =>
			p.distanceAlong(wires[0])
			+ p.distanceAlong(wires[1])
			+ 2 // include origin
		)
		.fold!min
		.writeln;
}

void main(string[] args)
{
	int part = 1;

	auto options = getopt(args,
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
