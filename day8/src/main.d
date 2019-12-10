import image;
import util;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.typecons;
import std.utf;

auto readPixels(File input)
{
	return input
		.byLine
		.joiner
		.map!(ch => (ch - '0').to!Pixel);
}

void partOne()
{
	auto image = Image!(25, 6).fromPixels(stdin.readPixels);

	size_t lid = image
		.layers
		.enumerate
		.map!(unpack!((index, layer) =>
			tuple!("index", "zeros")(
				index,
				layer.pixels.filter!(p => p == 0).count
			)
		))
		.minElement!(e => e.zeros)
		.index;

	size_t ones = image.layers[lid].pixels.filter!(p => p == 1).count;
	size_t twos = image.layers[lid].pixels.filter!(p => p == 2).count;

	writeln(ones * twos);
}

void partTwo()
{
	auto image = Image!(25, 6).fromPixels(stdin.readPixels);
	image.flattened.render(stdout.lockingTextWriter);
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

