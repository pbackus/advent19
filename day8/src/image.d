import util;

import std.algorithm;
import std.array;
import std.range;

alias Pixel = int;

struct Layer(size_t width, size_t height)
{
	Pixel[width][height] data;

	static Layer fromPixels(R)(R pixels)
		if (isInputRangeOf!(R, Pixel) && hasLength!R)
		in (pixels.length == width*height)
	{
		return Layer(
			pixels
				.chunks(width)
				.map!(chunk => chunk.staticArray!width)
				.staticArray!height
		);
	}

	auto rows()
	{
		return iota(height).map!(i => data[i][]);
	}

	auto pixels()
	{
		return this.rows.joiner;
	}

	void render(Output)(Output output)
		if (isOutputRange!(Output, dchar))
	{
		static immutable dchar[] symbols = [ 0: ' ', 1: '█' , 2: ' '];

		rows.each!((row) {
			row.each!((pixel) { put(output, symbols[pixel]); });
			put(output, '\n');
		});
	}
}

unittest {
	auto exampleLayer = Layer!(3, 2)([
		[1, 2, 3].staticArray,
		[4, 5, 6].staticArray
	]);

	assert(exampleLayer.rows.equal([[1, 2, 3], [4, 5,6]]));
}

unittest {
	auto exampleLayer = Layer!(2, 2)([
		[0, 1],
		[1, 0]
	]);
	auto output = appender!(dchar[]);

	exampleLayer.render(output);
	assert(output.data == [' ', '█', '\n', '█', ' ', '\n']);
}

struct Image(size_t width, size_t height)
{
	alias Layer = .Layer!(width, height);

	Layer[] layers;

	static Image fromPixels(R)(R pixels)
		if (isInputRangeOf!(R, Pixel))
	{
		return Image(
			pixels
				.chunks(width*height)
				.map!(chunk => chunk.takeExactly(width*height))
				.map!(Layer.fromPixels)
				.array
		);
	}

	Layer flattened()
	{
		return layers
			.fold!((top, bottom) => Layer.fromPixels(
				zip(top.pixels, bottom.pixels)
					.map!(pair => pair[0] == 2 ? pair[1] : pair[0])
					.takeExactly(width*height)
			));
	}
}

unittest {
	Pixel[] examplePixels = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2];
	auto exampleImage = Image!(3, 2).fromPixels(examplePixels);
	Pixel[][][] result = [
		[
			[1, 2, 3],
			[4, 5, 6]
		],
		[
			[7, 8, 9],
			[0, 1, 2]
		]
	];

	assert(exampleImage
		.layers
		.map!((ref layer) => layer.rows.array)
		.equal(result)
	);
}

unittest {
	Pixel[] examplePixels = [0, 2, 2, 2, 1, 1, 2, 2, 2, 2, 1, 2, 0, 0, 0, 0];
	auto exampleImage = Image!(2, 2).fromPixels(examplePixels);
	auto result = [
		[0, 1],
		[1, 0]
	];

	assert(exampleImage
		.flattened
		.rows
		.equal(result)
	);
}
