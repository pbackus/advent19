import util;
import wire;

import std.algorithm;
import std.conv;
import std.format;
import std.functional;
import std.getopt;
import std.range;
import std.stdio;

Wire readWire(const(char)[] line)
{
	return Wire(
		line
		.splitter(',')
		.map!(step => move(
			step[0].to!Direction,
			step[1 .. $].to!int
		))
		.pipe!(points => chain(only(Point(0, 0)), points))
		.cumulativeFold!((pos, move) => pos + move)(Point(0, 0))
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
	stdin.readWires.writeln;
}

void partTwo()
{
	return;
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
