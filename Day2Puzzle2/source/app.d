module day2puzzle2;

import std.stdio;

void main()
{
	// Note that this table of data is tab and newline delimited.
	auto input = `409	194	207	470	178	454	235	333	511	103	474	293	525	372	408	428
4321	2786	6683	3921	265	262	6206	2207	5712	214	6750	2742	777	5297	3764	167
3536	2675	1298	1069	175	145	706	2614	4067	4377	146	134	1930	3850	213	4151
2169	1050	3705	2424	614	3253	222	3287	3340	2637	61	216	2894	247	3905	214
99	797	80	683	789	92	736	318	103	153	749	631	626	367	110	805
2922	1764	178	3420	3246	3456	73	2668	3518	1524	273	2237	228	1826	182	2312
2304	2058	286	2258	1607	2492	2479	164	171	663	62	144	1195	116	2172	1839
114	170	82	50	158	111	165	164	106	70	178	87	182	101	86	168
121	110	51	122	92	146	13	53	34	112	44	160	56	93	82	98
4682	642	397	5208	136	4766	180	1673	1263	4757	4680	141	4430	1098	188	1451
158	712	1382	170	550	913	191	163	459	1197	1488	1337	900	1182	1018	337
4232	236	3835	3847	3881	4180	4204	4030	220	1268	251	4739	246	3798	1885	3244
169	1928	3305	167	194	3080	2164	192	3073	1848	426	2270	3572	3456	217	3269
140	1005	2063	3048	3742	3361	117	93	2695	1529	120	3480	3061	150	3383	190
489	732	57	75	61	797	266	593	324	475	733	737	113	68	267	141
3858	202	1141	3458	2507	239	199	4400	3713	3980	4170	227	3968	1688	4352	4168`;

	import std.conv : to;
	writeln("Checksum is " ~ checksum(input).to!string); 
}

@("Examples succeed")
unittest
{
	auto input = `5	9	2	8
9	4	7	3
3	8	6	5`;

	import std.algorithm : splitter;
	import std.range : array;
	auto lines = input.splitter("\n").array;
	assert(checksumLine(lines[0]) == 4);
	assert(checksumLine(lines[1]) == 3);
	assert(checksumLine(lines[2]) == 2);
	import std.conv : to;
	debug writeln("Checksum is " ~ checksum(input).to!string);
	assert(checksum(input) == 9);
}

auto findDivisibles(string input)
{
	import std.conv : to, parse;
	import std.algorithm : splitter, map, findAmong;
	import std.range : array;
	auto values = input.splitter("\t").array;
	debug writeln("Values" ~ values.to!string);
	auto integers = values.map!(v => v.parse!size_t).array;
	debug writeln("Integers" ~ integers.to!string);

	// I want to get a bunch of tuples of divisibles.
	import std.typecons : Tuple;
	alias Divisible = Tuple!(size_t, "first", size_t, "second");
	Divisible[] divisibles = [];

	// We're finding values where i divides j evenly.
	bool predicate(size_t i, size_t j)
	{
		bool found = i != j && (i % j == 0);
		string foundString = found ? " Found!" : "";
		debug writeln("Comparing i: " ~ i.to!string ~ " and j: " ~ j.to!string ~ foundString);

		if (found)
		{
			Divisible d;
			d.first = i;
			d.second = j;

			debug writeln("Found " ~ d.to!string);

			divisibles ~= d;
		}

		return false;
	}

	integers.findAmong!predicate(integers);

	debug writeln("Divides " ~ divisibles.to!string);

	return divisibles;
}

@("We can find divisible values")
unittest
{
	auto input = `5	9	2	8`;

	auto divisibles = findDivisibles(input);

	assert(divisibles.length == 1);
	assert(divisibles[0].first == 8);
	assert(divisibles[0].second == 2);
}

size_t checksumLine(string line)
{
	// Walk through the row and figure out pairs which divide evenly
	auto divisibles = findDivisibles(line);

	size_t checksum = 0;
	foreach (d; divisibles)
	{
		checksum += d.first / d.second;
	}

	return checksum;
}

size_t checksum(string input)
{
	size_t checksum = 0;

	import std.conv : to;
	import std.algorithm : splitter;
	
	auto lines = input.splitter("\n");
	debug writeln("Lines" ~ lines.to!string);

	foreach (l; lines)
	{
		checksum += checksumLine(l);
	}

	return checksum;
}