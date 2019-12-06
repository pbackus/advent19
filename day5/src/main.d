import intcode;

import std.algorithm;
import std.conv;
import std.format;
import std.getopt;
import std.range;
import std.stdio;

auto readProgram(File input)
{
	return input
		.byLine
		.map!(line =>
			line.splitter(',').map!(to!Word)
		)
		.joiner;
}

void partOne()
{
	auto program = stdin.readProgram;
	auto input = only(1);
	auto output = program.run(input);

	output.each!writeln;
}

void partTwo()
{
	auto program = stdin.readProgram;
	auto input = only(5);
	auto output = program.run(input);

	output.each!writeln;
}

void main(string[] args)
{
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
