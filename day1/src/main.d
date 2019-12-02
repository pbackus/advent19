static import one;
static import two;
import common;

import std.algorithm;
import std.conv;
import std.format;
import std.getopt;
import std.stdio;

auto byInt(File input)
{
	return input.byLine.map!(to!int);
}

void partOne()
{
	stdin
		.byInt
		.fuelTotal!(one.fuel)
		.writeln;
}

void partTwo()
{
	stdin
		.byInt
		.fuelTotal!(two.fuel)
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
