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

enum Point origin = Point(0, 0);

unittest {
	assert(Point(123, 0) + Point(0, 456) == Point(123, 456));
	assert(Point(1, 1) + Point(-1, -1) == origin);
	assert(origin + origin == origin);
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
	return distance(p, origin);
}

unittest {
	assert(distance(origin, Point(0, 5)) == 5);
	assert(distance(Point(0, 5), origin) == 5);
	assert(distance(Point(0, 5)) == 5);
	assert(distance(Point(0, 5), Point(0, 5)) == 0);
}

struct Segment
{
	private Point start_, end_;

	this(Point start, Point end)
		in (start.x == end.x || start.y == end.y)
	{
		start_ = start;
		end_ = end;
	}

	invariant(start_.x == end_.x || start_.y == end_.y);

	Point start()
	{
		return start_;
	}

	Point end()
	{
		return end_;
	}

	bool isHorizontal()
	{
		return start_.y == end_.y;
	}

	bool isVertical()
	{
		return start_.x == end_.x;
	}

	int top()
	{
		return max(start_.y, end_.y);
	}

	int bottom()
	{
		return min(start_.y, end_.y);
	}

	int left()
	{
		return min(start_.x, end_.x);
	}


	int right()
	{
		return max(start_.x, end_.x);
	}

	int x()
		in (isVertical)
	{
		return start_.x;
	}

	int y()
		in (isHorizontal)
	{
		return start_.y;
	}

	int length()
	{
		return distance(start, end);
	}
}

bool contains(Segment s, Point p)
{
	if (s.isHorizontal) {
		return p.y == s.y && s.left <= p.x && p.x <= s.right;
	} else {
		return p.x == s.x && s.bottom <= p.y && p.y <= s.top;
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

int distanceAlong(Point p, Wire w)
{
	int result = 0;

	foreach (s; w.segments) {
		if (s.contains(p)) {
			return result + distance(s.start, p);
		}

		result += s.length;
	}

	throw new Exception("Unreachable point.");
}
