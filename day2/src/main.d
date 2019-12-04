import computer;

import std.algorithm;
import std.array;
import std.conv;
import std.format;
import std.getopt;
import std.stdio;
import std.utf;


auto readProgram(File input)
{
	return input
		.byLine
		.map!(line =>
			line.splitter(',').map!(to!int)
		)
		.joiner;
}

void partOne()
{
	auto c = one.Computer(stdin.readProgram);
	c.memory[1] = 12;
	c.memory[2] = 2;
	c.run;
	writeln(c.memory[0]);
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
