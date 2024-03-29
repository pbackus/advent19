import password;

import std.algorithm;
import std.array;
import std.format;
import std.getopt;
import std.range;
import std.stdio;
import std.typecons;

const int[6] lower = [2, 4, 8, 3, 4, 5];
const int[6] upper = [7, 4, 6, 3, 1, 5];

void partOne()
{
	auto start = Password!(No.strict).above(lower);
	auto end = Password!(No.strict).above(upper);

	start
		.recurrence!((passwords, n) => passwords[n - 1].next)
		.until(end)
		.count
		.writeln;
}

void partTwo()
{
	auto start = Password!(Yes.strict).above(lower);
	auto end = Password!(Yes.strict).above(upper);

	start
		.recurrence!((passwords, n) => passwords[n - 1].next)
		.until(end)
		.count
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
