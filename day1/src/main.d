import first;

import std.algorithm;
import std.conv;
import std.getopt;
import std.stdio;

auto byInt(File input)
{
	return input.byLine.map!(to!int);
}

void main(string[] args)
{
	auto masses = stdin.byInt;
	masses.fuelTotal.writeln;
}
