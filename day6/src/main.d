import orbit;

import std.algorithm;
import std.array;
import std.format;
import std.functional;
import std.getopt;
import std.range;
import std.stdio;
import std.typecons;
import std.utf;

auto readOrbitMap(File input)
{
	return input
		.byLineCopy
		.map!(line =>
			line
				.splitter(')')
				.staticArray!2
				.pipe!(orbit =>
					tuple(orbit[0], orbit[1]))
		);
}

void partOne()
{
	System system = stdin.readOrbitMap.system;
	system["COM"].orbitCount.writeln;
}

void partTwo()
{
	return;
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
