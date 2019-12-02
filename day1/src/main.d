module main;

import first;

import std.stdio;
import std.conv;
import std.algorithm;

auto byInt(File input)
{
	return input.byLine.map!(to!int);
}

void main()
{
	auto masses = stdin.byInt;
	writeln(masses.totalFuel);
}
