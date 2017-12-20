module day3puzzle2;

import std.stdio : writeln;
import std.conv : to;

enum puzzleInput = 368078;
enum spoilerAlertDay3Puzzle1Output = 371;

void main()
{
	auto spiral = Spiralizer();

	import std.range : take, array;
	import std.algorithm : map;
	size_t[string] values;
	auto sums = spiral.map!((c) {
		auto valueToReturn = c.x == 0 && c.y == 0 ? 1 : sumAdjacentValues(c, values);
		values[c.x.to!string ~ ", " ~ c.y.to!string] = valueToReturn;

		return valueToReturn;
	});

	size_t answer = 0;

	foreach (s; sums)
	{
		if (s > puzzleInput)
		{
			answer = s;
			break;
		}
	}

	writeln("Spiral sum value greater than " ~ puzzleInput.to!string ~ " is " ~ answer.to!string); 
}

@("Examples succeed")
unittest
{
	auto spiral = Spiralizer();

	import std.range : take, array;
	import std.algorithm : map;
	size_t[string] values;
	auto sums = spiral.map!((c) {
		auto valueToReturn = c.x == 0 && c.y == 0 ? 1 : sumAdjacentValues(c, values);
		values[c.x.to!string ~ ", " ~ c.y.to!string] = valueToReturn;

		return valueToReturn;
	}).take(5).array;
	assert(sums[0] == 1);
	assert(sums[1] == 1);
	assert(sums[2] == 2);
	assert(sums[3] == 4);
	assert(sums[4] == 5);
}

import std.typecons : Tuple;
alias Coordinate = Tuple!(int, "x", int, "y");

struct Spiralizer
{
	size_t steps = 1;
	int x = 0;
	int y = 0;
	int widthX = 0;
	int widthY = 0;

	enum Direction
	{
		North,
		South,
		East,
		West,
	}

	auto direction = Direction.East;

	void step()
	{
		debug writeln("Heading in " ~ direction.to!string ~ " direction");

		final switch (direction)
		{
			case Direction.North:
			{
				y++;
				if (y > widthY)
				{
					widthY++;
					widthY = -widthY;
					direction = Direction.West;
				}
			} break;
			case Direction.South:
			{
				y--;
				if (y <= widthY)
				{
					widthY = -widthY;
					direction = Direction.East;
				}
			} break;
			case Direction.East:
			{
				x++;
				if (x > widthX)
				{
					widthX++;
					widthX = -widthX;
					direction = Direction.North;
				}
			} break;
			case Direction.West:
			{
				x--;
				if (x <= widthX)
				{
					widthX = -widthX;
					direction = Direction.South;
				}
			} break;
		}

		debug writeln("Steps: " ~ steps.to!string ~ " x, y: (" ~ x.to!string ~ ", " ~ y.to!string ~ ") resulting in widthX, widthY: (" ~ widthX.to!string ~ ", " ~ widthY.to!string ~ ")");

		steps++;
	}

	void popFront()
	{
		step();
	}

	bool empty = false;

	@property Coordinate front()
	{
		Coordinate c;
		c.x = x;
		c.y = y;

		return c;
	}
}

@("Spiralizer is an input range")
unittest
{
	import std.range : isInputRange;
	static assert(isInputRange!Spiralizer);
}

@("We can iterate to a position")
unittest
{
	auto spiral = Spiralizer();
	spiral.popFront();
	spiral.popFront();
	auto c = spiral.front;
	assert(c.x == 1);
	assert(c.y == 1);
}

@("We can solve day 3 puzzle 1 with the Spiralizer")
unittest
{
	size_t calculateManhattanDistance(int x1, int y1, int x2, int y2)
	{
		import std.math;

		return abs(x1 - x2) + abs(y1 - y2);
	}

	auto spiral = Spiralizer();
	
	import std.range : take, array;

	// Make an array of values from the range
	auto values = spiral.take(puzzleInput).array;

	// Get the last one
	auto last = values[$ - 1];

	auto distance = calculateManhattanDistance(last.x, last.y, 0, 0);
	assert(distance == spoilerAlertDay3Puzzle1Output);
}

@("We can store a value to a position")
unittest
{
	// TODO: This could be better!  Figure out how to make an infinite sparse 2D matrix range that I can plot integers into.

	auto spiral = Spiralizer();

	import std.range : take;
	auto fiveIterations = spiral.take(5);
	size_t[string] values;

	enum seven = 7;

	import std.algorithm : each;

	// Put a 7 in
	fiveIterations.each!(c => values[c.x.to!string ~ ", " ~ c.y.to!string] = seven);

	// Check that we have 7s
	fiveIterations.each!(c => values[c.x.to!string ~ ", " ~ c.y.to!string] == seven);
}

@("We can retrieve and sum adjacent values")
unittest
{
	auto spiral = Spiralizer();

	import std.range : take;
	auto coordinates = spiral.take(5);
	size_t[string] values;

	debug writeln("We're going to iterate over these coordinates: " ~ coordinates.to!string);

	import std.algorithm : each;
	coordinates.each!(c => values[c.x.to!string ~ ", " ~ c.y.to!string] = c.x == 0 && c.y == 0 ? 1 : sumAdjacentValues(c, values));

	debug writeln("Resulting values: " ~ values.to!string);

	size_t getValueAtCoordinate(Coordinate c, const size_t[string] values)
	{
		auto key = c.x.to!string ~ ", " ~ c.y.to!string;
		if (key in values)
		{
			debug writeln("Found key: " ~ key.to!string ~ " in values: " ~ values.to!string);
			return values[key];
		}

		return 0;
	}

	// Iterate over the values
	import std.range : array;
	auto a = coordinates.array;
	auto c1 = a[0];
	auto c2 = a[1];
	auto c3 = a[2];
	auto c4 = a[3];
	auto c5 = a[4];
	assert(getValueAtCoordinate(c1, values) == 1);
	assert(getValueAtCoordinate(c2, values) == 1);
	assert(getValueAtCoordinate(c3, values) == 2);
	assert(getValueAtCoordinate(c4, values) == 4);
	assert(getValueAtCoordinate(c5, values) == 5);
}

size_t sumAdjacentValues(Coordinate c, const size_t[string] values)
{
	size_t sum = 0;

	// Try all the directions, including diagonals
	auto northOne = c;
	northOne.y += 1;
	auto southOne = c;
	southOne.y -= 1;
	auto eastOne = c;
	eastOne.x += 1;
	auto westOne = c;
	westOne.x -= 1;
	auto northWestOne = c;
	northWestOne.x += 1;
	northWestOne.y -= 1;
	auto southWestOne = c;
	southWestOne.x -= 1;
	southWestOne.y -= 1;
	auto northEastOne = c;
	northEastOne.x += 1;
	northEastOne.y += 1;
	auto southEastOne = c;
	southEastOne.x -= 1;
	southEastOne.y += 1;

	debug writeln("We are at coordinate: " ~ c.to!string);

	import std.algorithm : each;
	[northOne, southOne, eastOne, westOne, northWestOne, southWestOne, northEastOne, southEastOne].each!((d) {
		auto key = d.x.to!string ~ ", " ~ d.y.to!string;
		debug writeln("Checking for value at coordinate: " ~ d.to!string);
		if (key in values)
		{
			sum += values[key];
			debug writeln("Adding value to sum: " ~ values[key].to!string);
		}
	});

	debug writeln("Sum is: " ~ sum.to!string);

	return sum;
}