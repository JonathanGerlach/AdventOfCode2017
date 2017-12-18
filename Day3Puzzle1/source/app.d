module day3puzzle1;

import std.stdio : writeln;
import std.conv : to;

void main()
{
	auto input = 368078;

	import std.conv : to;
	writeln("Spiral Distances is " ~ calculateSpiralDistance(368078).to!string); 
}

@("Examples succeed")
unittest
{
	assert(calculateSpiralDistance(1) == 0);
	assert(calculateSpiralDistance(12) == 3);
	assert(calculateSpiralDistance(23) == 2);
	assert(calculateSpiralDistance(1024) == 31);
}

size_t calculateSpiralDistance(int input)
{
	size_t step = 1;
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

	while (step < input)
	{
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

		debug writeln("Step: " ~ step.to!string ~ " x, y: (" ~ x.to!string ~ ", " ~ y.to!string ~ ") resulting in widthX, widthY: (" ~ widthX.to!string ~ ", " ~ widthY.to!string ~ ")");

		step++;
	}

	auto distance = calculateManhattanDistance(x, y, 0, 0);

	debug writeln("Distance: " ~ distance.to!string ~ " Step: " ~ step.to!string);

	return distance;
}

@("We can calculate a basic Manhattan Distance")
unittest
{	
	assert(calculateManhattanDistance(6, 6, 0, 0) == 12);
}

@("We can calculate the Manhattan Distance in the examples")
unittest
{	
	assert(calculateManhattanDistance(0, 0, 0, 0) == 0);
	assert(calculateManhattanDistance(2, 1, 0, 0) == 3);
	assert(calculateManhattanDistance(0, -2, 0, 0) == 2);
//	assert(calculateManhattanDistance(?, ?, 0, 0) == 31); ???

}

size_t calculateManhattanDistance(int x1, int y1, int x2, int y2)
{
	import std.math;

	return abs(x1 - x2) + abs(y1 - y2);
}