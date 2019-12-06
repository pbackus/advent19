import util;

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
	JumpIfTrue = 5,
	JumpIfFalse = 6,
	LessThan = 7,
	Equals = 8,
	Halt = 99
}

size_t increment(Opcode opcode)
{
	final switch(opcode) with (Opcode) {
		case Add:
		case Multiply:
		case LessThan:
		case Equals:
			return 4;
		case Read:
		case Write:
			return 2;
		case JumpIfTrue:
		case JumpIfFalse:
			return 3;
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

Word digits(Word word, uint lsd, uint count)
	in (count > 0)
{
	return (word / 10^^lsd) % 10^^count;
}

unittest {
	assert(12345.digits(1, 3) == 234);
	assert(1.digits(0, 2) == 01);
}

Word digit(Word word, Word d)
{
	return word.digits(d, 1);
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
	if (isInputRangeOf!(Input, Word) && isOutputRange!(Output, Word))
{
	Word[] memory;
	Instruction instruction;
	size_t pc = 0;

	Input input;
	Output output;

	this(Program)(Program program, Input input, Output output)
		if (isInputRangeOf!(Program, Word))
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

	private void binaryOp(string op)()
	{
		storeArg(2, mixin("fetchArg(0) ", op, " fetchArg(1)"));
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
				binaryOp!"+";
				break;
			case Multiply:
				binaryOp!"*";
				break;
			case Read:
				storeArg(0, read);
				break;
			case Write:
				write(fetchArg(0));
				break;
			case JumpIfTrue:
				if (fetchArg(0)) {
					pc = fetchArg(1);
					return;
				}
				break;
			case JumpIfFalse:
				if (!fetchArg(0)) {
					pc = fetchArg(1);
					return;
				}
				break;
			case LessThan:
				binaryOp!"<";
				break;
			case Equals:
				binaryOp!"==";
				break;
			case Halt:
				return;
		}

		pc += instruction.opcode.increment;
	}

	bool halted() const
	{
		return instruction.opcode == Opcode.Halt;
	}

	void run()
	{
		while (!halted) { step; }
	}
}

Computer!(Input, Output)
computer(
	Program,
	Input = Word[],
	Output = NullSink
)(
	Program program,
	Input input = Input.init,
	Output output = Output.init
)
	if (
		isInputRangeOf!(Program, Word)
		&& isInputRangeOf!(Input, Word)
		&& isOutputRange!(Output, Word)
	)
{
	return Computer!(Input, Output)(program, input, output);
}

Word[] run(Program, Input)(Program program, Input input)
	if (isInputRangeOf!(Program, Word) && isInputRangeOf!(Input, Word))
{
	auto output = appender!(Word[]);
	auto computer = computer(program, input, output);

	computer.run;
	return output.data;
}

unittest {
	Word[] eqlEightPos = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8];
	Word[] ltEightPos = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8];
	Word[] eqlEightImm = [3, 3, 1108, -1, 8, 3, 4, 3, 99];
	Word[] ltEightImm = [3, 3, 1107, -1, 8, 3, 4, 3, 99];

	assert(eqlEightPos.run(only(8)) == [1]);
	assert(eqlEightPos.run(only(1)) == [0]);

	assert(ltEightPos.run(only(8)) == [0]);
	assert(ltEightPos.run(only(1)) == [1]);

	assert(eqlEightImm.run(only(8)) == [1]);
	assert(eqlEightImm.run(only(1)) == [0]);

	assert(ltEightImm.run(only(8)) == [0]);
	assert(ltEightImm.run(only(1)) == [1]);
}

unittest {
	Word[] nonZeroPos = [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9];
	Word[] nonZeroImm = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1];

	assert(nonZeroPos.run(only(1)) == [1]);
	assert(nonZeroPos.run(only(0)) == [0]);

	assert(nonZeroImm.run(only(1)) == [1]);
	assert(nonZeroImm.run(only(0)) == [0]);
}

unittest {
	Word[] cmpEight = [
		3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 
		1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 
		999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99
	];

	assert(cmpEight.run(only(7)) == [999]);
	assert(cmpEight.run(only(8)) == [1000]);
	assert(cmpEight.run(only(9)) == [1001]);
}
