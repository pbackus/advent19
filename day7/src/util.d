import std.range.primitives;

enum bool isInputRangeOf(R, E) =
	isInputRange!R && is(ElementType!R : E);

struct LazyGenerator(alias fun)
{
	private alias T = typeof(fun());

	private bool hasFront = false;
	private T front_;

	enum bool empty = false;

	@property T front()
	{
		if (!hasFront) {
			front_ = fun();
		}
		return front_;
	}

	void popFront()
	{
		hasFront = false;
	}
}

auto lazyGenerate(alias fun)()
{
	return LazyGenerator!fun();
}

unittest {
	int n = 0;
	auto dg = () => n++;
	auto gen = lazyGenerate!dg;

	assert(n == 0);
	assert(gen.front == 0);
	assert(n == 1);
	assert(gen.front == 1);
}
