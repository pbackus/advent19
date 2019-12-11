import util;

import std.algorithm;
import std.range;
import std.traits;

struct Point
{
	int x, y;

	Point opBinary(string op : "+")(Point rhs)
	{
		return Point(x + rhs.x, y + rhs.y);
	}

	Point opBinary(string op : "-")(Point rhs)
	{
		return Point(x - rhs.x, y - rhs.y);
	}

	Point opBinary(string op : "*", T)(T n)
		if (isIntegral!T)
	{
		return Point(cast(int) (x*n), cast(int) (y*n));
	}

	Point opBinary(string op : "/", T)(T n)
		if (isIntegral!T)
	{
		return Point(cast(int) (x/n), cast(int) (y/n));
	}
}

enum Point origin = Point(0, 0);

unittest {
	assert(Point(123, 0) + Point(0, 456) == Point(123, 456));
	assert(Point(123, 0) - Point(0, 456) == Point(123, -456));
	assert(Point(1, 1) + Point(-1, -1) == origin);
	assert(Point(1, 1) - Point(1, 1) == origin);
	assert(origin + origin == origin);
	assert(origin - origin == origin);
}

unittest {
	assert(origin * 2 == origin);
	assert(origin / 2 == origin);
	assert(Point(123, 456) * 2 == Point(246, 912));
	assert(Point(246, 912) / 2 == Point(123, 456));
}

Point reduced(Point p)
{
	import std.math: abs;
	import std.numeric: gcd;

	int d = gcd(abs(p.x), abs(p.y));
	if (d == 0) { return p; }
	return Point(p.x/d, p.y/d);
}

unittest {
	assert(Point(3, 7).reduced == Point(3, 7));
	assert(Point(2, 2).reduced == Point(1, 1));
	assert(Point(-2, 2).reduced == Point(-1, 1));
}

auto line(Point start, Point slope)
	in (slope != origin)
{
	return sequence!((state, n) =>
		state.unpack!((start, slope) =>
			start + slope*n
		)
	)(start, slope.reduced);
}

unittest {
	assert(line(origin, Point(1, 1))
		.take(3)
		.equal([Point(0, 0), Point(1, 1), Point(2, 2)])
	);
}

template isMap(T)
{
	static if (isRandomAccessRange!T && hasLength!T) {
		alias E = ElementType!T;
		enum isMap =
			isRandomAccessRange!E
			&& hasLength!E
			&& is(ElementType!E : bool);
	} else {
		enum isMap = false;
	}
}

unittest {
	static assert(isMap!(bool[][]));
}

bool includes(Map)(Map map, Point p)
	if (isMap!Map)
{
	if (map.length == 0) { return false; }
	return 0 <= p.y && p.y < map.length
		&& 0 <= p.x && p.x < map[0].length;
}

unittest {
	bool[][] exampleMap = [[1, 1]];

	assert( exampleMap.includes(Point(1, 0)));
	assert(!exampleMap.includes(Point(2, 0)));
	assert(!exampleMap.includes(Point(0, 1)));
}

bool canSee(Map)(Point from, Point to, Map map)
	if (isMap!Map)
{
	import std.typecons: No;

	if (from == to) {
		return false;
	}

	return line(from, to - from)
		.dropOne
		.until!(p => !map.includes(p))
		.until!(p => map[p.y][p.x])(No.openRight)
		.canFind(to);
}

unittest {
	bool[][] exampleMap = [
		[1, 0, 0],
		[0, 1, 0],
		[1, 0, 1],
	];
	
	assert( Point(0, 0).canSee(Point(1, 1), exampleMap));
	assert( Point(1, 1).canSee(Point(0, 0), exampleMap));
	assert( Point(0, 0).canSee(Point(0, 2), exampleMap));
	assert( Point(0, 0).canSee(Point(2, 1), exampleMap));
	assert(!Point(0, 0).canSee(Point(0, 0), exampleMap));
	assert(!Point(0, 0).canSee(Point(2, 2), exampleMap));
	assert(!Point(0, 2).canSee(Point(2, 0), exampleMap));
}

bool[][] parseMap(R)(R range)
	if (isInputRange!R && isInputRange!(ElementType!R))
{
	return range
		.map!(row => row.map!(ch => ch == '#').array)
		.array;
}

unittest {
	string[] example = [
		".#..#",
		".....",
		"#####",
		"....#",
		"...##"
	];
	bool[][] result = [
		[0, 1, 0, 0, 1],
		[0, 0, 0, 0, 0],
		[1, 1, 1, 1, 1],
		[0, 0, 0, 0, 1],
		[0, 0, 0, 1, 1]
	];
	
	assert(parseMap(example).equal(result));
}

auto points(Map)(Map map)
	if (isMap!Map)
{
	return cartesianProduct(
		iota(map.length == 0 ? 0 : cast(int) map[0].length),
		iota(cast(int) map.length)
	).map!(tup => Point(tup.expand));
}

size_t visibleAsteroids(Map)(Point from, Map map)
	if (isMap!Map)
{
	return map
		.points
		.filter!(end => map[end.y][end.x] && from.canSee(end, map))
		.count;
}

unittest {
	bool[][] map1 = parseMap([
		"......#.#.",
		"#..#.#....",
		"..#######.",
		".#.#.###..",
		".#..#.....",
		"..#....#.#",
		"#..#....#.",
		".##.#..###",
		"##...#..#.",
		".#....####"
	]);
	bool[][] map2 = parseMap([
		"#.#...#.#.",
		".###....#.",
		".#....#...",
		"##.#.#.#.#",
		"....#.#.#.",
		".##..###.#",
		"..#...##..",
		"..##....##",
		"......#...",
		".####.###."
	]);
	bool[][] map3 = parseMap([
		".#..#..###",
		"####.###.#",
		"....###.#.",
		"..###.##.#",
		"##.##.#.#.",
		"....###..#",
		"..#.#..#.#",
		"#..#.#.###",
		".##...##.#",
		".....#.#.."
	]);
	bool[][] map4 = parseMap([
		".#..##.###...#######",
		"##.############..##.",
		".#.######.########.#",
		".###.#######.####.#.",
		"#####.##.#.##.###.##",
		"..#####..#.#########",
		"####################",
		"#.####....###.#.#.##",
		"##.#################",
		"#####.##.###..####..",
		"..######..##.#######",
		"####.##.####...##..#",
		".#####..#.######.###",
		"##...#.##########...",
		"#.##########.#######",
		".####.#.###.###.#.##",
		"....##.##.###..#####",
		".#.#.###########.###",
		"#.#.#.#####.####.###",
		"###.##.####.##.#..##",
	]);

	assert(visibleAsteroids(Point(5, 8), map1) == 33);
	assert(visibleAsteroids(Point(1, 2), map2) == 35);
	assert(visibleAsteroids(Point(6, 3), map3) == 41);
	assert(visibleAsteroids(Point(11, 13), map4) == 210);
}
