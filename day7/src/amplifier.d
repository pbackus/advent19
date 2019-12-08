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

void amplifierThread(
	immutable Word[] program,
	Word phase,
	bool first,
	bool last
)
{
	import util;
	import std.concurrency;
	import std.range;

	Tid next;
	bool gotNext = false;
	auto inputBuffer = appender!(Word[]);

	while (!gotNext) {
		receive(
			(Tid tid) { next = tid; gotNext = true; },
			(Word w)  { put(inputBuffer, w); yield; }
		);
	}

	Word lastOutput;

	auto input = chain(
		only(phase),
		only(0).take(first),
		inputBuffer.data,
		lazyGenerate!(() => receiveOnly!Word)
	);
	auto output = (Word w) {
		next.send(w);
		lastOutput = w;
	};

	auto controller = computer(program, input, output);
	controller.run;
	if (last) { ownerTid.send(lastOutput); }
}

Word runFeedback(immutable Word[] program, Word[5] phases)
{
	import std.algorithm;
	import std.array;
	import std.concurrency;

	Tid[5] threads;

	foreach (i; 0 .. 5) {
		threads[i] = spawn(
			&amplifierThread,
			program,
			phases[i],
			i == 0,
			i == 4
		);
	}

	foreach (i; 0 .. 5) {
		threads[i].send(i == 4 ? threads[0] : threads[i + 1]);
	}

	return receiveOnly!Word;
}

unittest {
	immutable Word[] example1 = [
		3, 26, 1001, 26, -4, 26, 3, 27, 1002, 27, 2, 27, 1, 27, 26,
		27, 4, 27, 1001, 28, -1, 28, 1005, 28, 6, 99, 0, 0, 5
	];

	immutable Word[] example2 = [
		3, 52, 1001, 52, -5, 52, 3, 53, 1, 52, 56, 54, 1007, 54, 5, 55, 1005,
		55, 26, 1001, 54, -5, 54, 1105, 1, 12, 1, 53, 54, 53, 1008, 54, 0, 55,
		1001, 55, 1, 55, 2, 53, 55, 53, 4, 53, 1001, 56, -1, 56, 1005, 56, 6,
		99, 0, 0, 0, 0, 10
	];

	assert(example1.runFeedback([9, 8, 7, 6, 5]) == 139629729);
	assert(example2.runFeedback([9, 7, 8, 5, 6]) == 18216);
}

Word maxThrustWithFeedback(immutable Word[] program)
{
	import std.algorithm;
	import std.range;

	Word result = Word.min;

	foreach (permutation; iota(5, 10).permutations) {
		Word[5] phases = permutation.staticArray!5;
		Word output = program.runFeedback(phases);
		if (output > result) result = output;
	}

	return result;
}

unittest {
	immutable Word[] example1 = [
		3, 26, 1001, 26, -4, 26, 3, 27, 1002, 27, 2, 27, 1, 27, 26,
		27, 4, 27, 1001, 28, -1, 28, 1005, 28, 6, 99, 0, 0, 5
	];

	immutable Word[] example2 = [
		3, 52, 1001, 52, -5, 52, 3, 53, 1, 52, 56, 54, 1007, 54, 5, 55, 1005,
		55, 26, 1001, 54, -5, 54, 1105, 1, 12, 1, 53, 54, 53, 1008, 54, 0, 55,
		1001, 55, 1, 55, 2, 53, 55, 53, 4, 53, 1001, 56, -1, 56, 1005, 56, 6,
		99, 0, 0, 0, 0, 10
	];

	assert(example1.maxThrustWithFeedback == 139629729);
	assert(example2.maxThrustWithFeedback == 18216);
}
