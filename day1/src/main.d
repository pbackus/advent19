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

int firstSolution()
{
	return stdin.byInt.fuelTotal!(first.fuel);
}

int secondSolution()
{
	return stdin.byInt.fuelTotal!(second.fuel);
}

void main(string[] args)
{
	bool partTwo = false;

	getopt(args, "2", &partTwo);

	if (!partTwo) {
		writeln(firstSolution);
	} else {
		writeln(secondSolution);
	}
}
