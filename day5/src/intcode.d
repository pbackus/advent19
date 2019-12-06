import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.range;

alias Word = int;

enum Opcode
{
	Add = 1,
	Multiply = 2,
	Read = 3,
	Write = 4,
	Halt = 99
}

size_t increment(Opcode opcode)
{
	final switch(opcode) with (Opcode) {
		case Add:
			return 4;
		case Multiply:
			return 4;
		case Read:
			return 2;
		case Write:
			return 2;
		case Halt:
			return 1;
	}
}

enum Mode
{
	Position = 0,
	Immediate = 1
}

struct Instruction
{
	Opcode opcode;
	Mode[3] modes;
}

Word digits(Word n, uint lsd, uint count)
	in (count > 0)
{
	return (n / 10^^lsd) % 10^^count;
}

unittest {
	assert(12345.digits(1, 3) == 234);
	assert(1.digits(0, 2) == 01);
}

Word digit(Word n, Word d)
{
	return digits(n, d, 1);
}

unittest {
	assert(12345.digit(3) == 2);
	assert(0.digit(0) == 0);
	assert(1.digit(1) == 0);
}

Opcode opcode(Word word)
{
	return word.digits(0, 2).to!Opcode;
}

unittest {
	with (Opcode) {
		assert(1002.opcode == Multiply);
	}
}

Mode[3] modes(Word word)
{
	return 
		only(
			word.digit(2),
			word.digit(3),
			word.digit(4)
		)
		.map!(to!Mode)
		.staticArray!3;
}

unittest {
	with (Mode) {
		assert(1002.modes == [Position, Immediate, Position]);
	}
}

Instruction decode(Word word)
{
	return Instruction(
		word.opcode,
		word.modes,
	);
}

unittest {
	with (Opcode) with (Mode) {
		assert(
			decode(1002)
			==
			Instruction(
				Multiply,
				[Position, Immediate, Position],
			)
		);
	}
}

struct Computer(Input, Output)
	if (
		isInputRange!Input && is(ElementType!Input : Word)
		&& isOutputRange!(Output, Word)
	)
{
	Word[] memory;
	Instruction instruction;
	size_t pc = 0;

	Input input;
	Output output;

	this(Program)(Program program, Input input, Output output)
		if (isInputRange!Program && is(ElementType!Program : Word))
	{
		memory = program.map!(to!Word).array;
		this.input = input;
		this.output = output;
	}

	private Word fetch(Word addr, Mode mode)
	{
		final switch (mode) with (Mode) {
			case Position:
				return memory[addr];
			case Immediate:
				return addr;
		}
	}

	private void store(Word addr, Mode mode, Word val)
	{
		final switch (mode) with (Mode) {
			case Position:
				memory[addr] = val;
				break;
			case Immediate:
				throw new Exception("Invalid operation: immediate store");
		}
	}

	private Word arg(size_t i)
	{
		return memory[pc + 1 + i];
	}

	private Word fetchArg(size_t i)
	{
		return fetch(arg(i), instruction.modes[i]);
	}

	private void storeArg(size_t i, Word val)
	{
		store(arg(i), instruction.modes[i], val);
	}

	private Word read()
	{
		enforce(!input.empty, "Runtime error: read past end of input");
		scope(success) input.popFront;
		return input.front;
	}

	private void write(Word val)
	{
		put(output, val);
	}

	void step()
	{
		instruction = memory[pc].decode;

		final switch (instruction.opcode) with (Opcode) {
			case Add:
				storeArg(2, fetchArg(0) + fetchArg(1));
				break;
			case Multiply:
				storeArg(2, fetchArg(0) * fetchArg(1));
				break;
			case Read:
				storeArg(0, read);
				break;
			case Write:
				write(fetchArg(0));
				break;
			case Halt:
				return;
		}

		pc += increment(instruction.opcode);
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

auto computer(
	Program,
	Input = Word[],
	Output = NullSink
)(
	Program program,
	Input input = Input.init,
	Output output = Output.init
)
	if (
		isInputRange!Program && is(ElementType!Program : Word)
		&& isInputRange!Input && is(ElementType!Input : Word)
		&& isOutputRange!(Output, Word)
	)
{
	return Computer!(Input, Output)(program, input, output);
}
