import intcode;

public import intcode: Word;

struct Amplifier
{
	Word phase;
	Word[] program;

	this(Word[] program, Word phase)
	{
		this.phase = phase;
		this.program = program;
	}
}

Word run(Amplifier amp, Word input)
{
	import std.algorithm;
	import std.range;

	Word output;
	auto controller = computer(
		amp.program,
		only(amp.phase, input),
		(Word w) { output = w; }
	);
	controller.run;
	return output;
}

Word maxThrust(Word[] program)
{
	import std.algorithm;
	import std.range;

	return iota(5)
		.permutations
		.map!(phases => phases
			.map!(phase => Amplifier(program, phase))
			.fold!((input, amp) => amp.run(input))(0)
		)
		.fold!max;
}

unittest {
	Word[] example1 = [
		3, 15, 3, 16, 1002, 16, 10, 16, 1, 16, 15, 15, 4, 15, 99, 0, 0
	];
	Word[] example2 = [
		3, 23, 3, 24, 1002, 24, 10, 24, 1002, 23, -1, 23, 
		101, 5, 23, 23, 1, 24, 23, 23, 4, 23, 99, 0, 0
	];
	Word[] example3 = [
		3, 31, 3, 32, 1002, 32, 10, 32, 1001, 31, -2, 31, 1007, 31, 0, 33, 
		1002, 33, 7, 33, 1, 33, 31, 31, 1, 32, 31, 31, 4, 31, 99, 0, 0, 0
	];

	assert(example1.maxThrust == 43210);
	assert(example2.maxThrust == 54321);
	assert(example3.maxThrust == 65210);
}
