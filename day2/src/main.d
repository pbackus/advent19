import computer;

import std.algorithm;
import std.array;
import std.conv;
import std.format;
import std.functional;
import std.getopt;
import std.range;
import std.stdio;
import std.typecons;
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

alias unpack(alias fun) = tup => fun(tup.expand);

void partOne()
{
	auto c = Computer(stdin.readProgram);
	c.memory[1] = 12;
	c.memory[2] = 2;
	c.run;
	writeln(c.memory[0]);
}

void partTwo()
{
	int[] program = stdin.readProgram.array;

	cartesianProduct(iota(0, 100), iota(0, 100))
		.find!(unpack!((noun, verb) {
			auto c = Computer(program);
			c.noun = noun;
			c.verb = verb;
			c.run;
			return c.output == 19690720;
		}))
		.front
		.unpack!((noun, verb) {
			writeln(100 * noun + verb);
		});
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
