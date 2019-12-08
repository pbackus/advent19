import amplifier;

import std.stdio;

auto readProgram(File input)
{
	import std.algorithm;
	import std.conv;
	import std.range;

	return input
		.byLine
		.map!(line =>
			line.splitter(',').map!(to!Word)
		)
		.joiner;
}

void partOne()
{
	import std.array;

	stdin
		.readProgram
		.array
		.maxThrust
		.writeln;
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
