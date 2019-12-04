import std.algorithm;
import std.array;
import std.conv;
import std.range.primitives;

enum Opcode
{
	Add = 1,
	Mul = 2,
	Halt = 99
}

struct Computer
{
	int[] memory;
	size_t pc = 0;

	this(R)(R program)
		if (isInputRange!R && is(ElementType!R : int))
	{
		memory = program.map!(to!int).array;
	}

	private ref int indirect(size_t addr)
	{
		return memory[memory[addr]];
	}

	void step()
	{
		Opcode op = memory[pc].to!Opcode;

		final switch (op) with (Opcode) {
			case Add:
				indirect(pc + 3) = indirect(pc + 1) + indirect(pc + 2);
				break;
			case Mul:
				indirect(pc + 3) = indirect(pc + 1) * indirect(pc + 2);
				break;
			case Halt:
				return;
		}

		pc += 4;
	}

	bool halted() const
	{
		return memory[pc] == Opcode.Halt;
	}

	void run()
	{
		while (!halted) { step; }
	}
}

int[] finalState(R)(R program)
	if (isInputRange!R && is(ElementType!R : int))
{
	Computer c = Computer(program);
	c.run;
	return c.memory;
}

unittest {
	assert([1, 0, 0, 0, 99].finalState == [2, 0, 0, 0, 99]);
	assert([2, 3, 0, 3, 99].finalState == [2, 3, 0, 6, 99]);
	assert([2, 4, 4, 5, 99, 0].finalState == [2, 4, 4, 5, 99, 9801]);
	assert([1, 1, 1, 4, 99, 5, 6, 0, 99].finalState == [30, 1, 1, 4, 2, 5, 6, 0, 99]);
}