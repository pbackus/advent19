import util;

import std.algorithm;
import std.math;
import std.range;

enum Direction : char
{
	Up = 'U',
	Down = 'D',
	Left = 'L',
	Right = 'R'
}

struct Point
{
	int x, y;

	Point opBinary(string op : "+")(Point rhs)
	{
		return Point(x + rhs.x, y + rhs.y);
	}
}

unittest {
	assert(Point(123, 0) + Point(0, 456) == Point(123, 456));
	assert(Point(1, 1) + Point(-1, -1) == Point(0, 0));
	assert(Point(0, 0) + Point(0, 0) == Point(0, 0));
}

Point move(Direction direction, int distance)
{
	final switch (direction) with (Direction)
	{
		case Up:
			return Point(0, distance);
		case Down:
			return Point(0, -distance);
		case Left:
			return Point(-distance, 0);
		case Right:
			return Point(distance, 0);
	}
}

int distance(Point a, Point b)
{
	return abs(a.x - b.x) + abs(a.y - b.y);
}

int distance(Point p)
{
	return distance(p, Point(0, 0));
}

unittest {
	assert(distance(Point(0, 0), Point(0, 5)) == 5);
	assert(distance(Point(0, 5), Point(0, 0)) == 5);
	assert(distance(Point(0, 5)) == 5);
	assert(distance(Point(0, 5), Point(0, 5)) == 0);
}

struct Segment
{
	private bool vertical;
	private Point bottomLeft;
	private int length;

	this(Point start, Point end)
		in (start.x == end.x || start.y == end.y)
	{
		vertical = start.x == end.x;
		bottomLeft = Point(min(start.x, end.x), min(start.y, end.y));
		length = distance(start, end);
	}

	bool isHorizontal()
	{
		return !vertical;
	}

	bool isVertical()
	{
		return vertical;
	}

	int top()
	{
		return bottomLeft.y + (isVertical ? length : 0);
	}

	int bottom()
	{
		return bottomLeft.y;
	}

	int left()
	{
		return bottomLeft.x;
	}


	int right()
	{
		return bottomLeft.x + (isHorizontal ? length : 0);
	}

	int x()
		in (isVertical)
	{
		return bottomLeft.x;
	}

	int y()
		in (isHorizontal)
	{
		return bottomLeft.y;
	}
}

Point[] intersections(Segment a, Segment b)
{
	if (a.isHorizontal && b.isVertical)
	{
		int x = b.x;
		int y = a.y;

		if (
			a.left <= x && x <= a.right
			&& b.bottom <= y && y <= b.top
		) {
			return [Point(x, y)];
		}
	} else if (a.isVertical && b.isHorizontal) {
		return intersections(b, a);
	} else if (a.isHorizontal && b.isHorizontal) {
		if (a.y == b.y) {
			int overlapLeft = max(a.left, b.left);
			int overlapRight = min(a.right, b.right);

			if (overlapLeft <= overlapRight) {
				return iota(overlapLeft, overlapRight + 1)
					.map!(x => Point(x, a.y))
					.array;
			}
		}
	} else if (a.isVertical && b.isVertical) {
		if (a.x == b.x) {
			int overlapBottom = max(a.bottom, b.bottom);
			int overlapTop = min(a.top, b.top);

			if (overlapBottom <= overlapTop) {
				return iota(overlapBottom, overlapTop + 1)
					.map!(y => Point(a.x, y))
					.array;
			}
		}
	}

	// Didn't find any intersections
	return [];
}

unittest {
	Segment h0 = Segment(Point(-1, 0), Point(1, 0));
	Segment h1 = Segment(Point(0, 0), Point(2, 0));
	Segment v0 = Segment(Point(0, -1), Point(0, 1));
	Segment v1 = Segment(Point(1, -1), Point(1, 1));

	assert(intersections(h0, h1).canFind(Point(0, 0)));
	assert(intersections(h0, h1).canFind(Point(1, 0)));
	assert(intersections(h0, v0) == [Point(0, 0)]);
	assert(intersections(h0, v1) == [Point(1, 0)]);
	assert(intersections(h1, v0) == [Point(0, 0)]);
	assert(intersections(h1, v1) == [Point(1, 0)]);
	assert(intersections(v0, v1) == []);
}

struct Wire
{
	Segment[] segments;
}

auto intersections(Wire a, Wire b)
{
	return cartesianProduct(a.segments, b.segments)
		.map!(unpack!((sa, sb) => intersections(sa, sb)))
		.joiner;
}
