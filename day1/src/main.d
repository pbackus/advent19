static import first;
static import second;
import common;

import std.algorithm;
import std.conv;
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
		.fuelTotal!(first.fuel)
		.writeln;
}

void partTwo()
{
	stdin
		.byInt
		.fuelTotal!(second.fuel)
		.writeln;
}

void main(string[] args)
{
	int part = 1;

	getopt(args, "part|p", &part);

	if (part == 1) {
		partOne;
	} else if (part == 2) {
		partTwo;
	}
}
