MATCH(n) DETACH DELETE n;

WITH 'L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL' AS input
WITH split(input, '\n') AS lines
WITH lines, size(lines[0]) AS lineSize, size(lines) AS linesCount
FOREACH (y IN range(0, linesCount-1)|
  FOREACH (x IN range(0, lineSize-1)|
    MERGE (location:Location{posX:x, posY:y}) SET location.hasSeat=substring(lines[y], x, 1)='L', location.occupied=false
    MERGE (rightLocation:Location{posX:(x+1), posY:y})
    MERGE (location)-[:NEXT_TO]->(rightLocation)
    MERGE (downLocation:Location{posX:x, posY:(y+1)})
    MERGE (location)-[:NEXT_TO]->(downLocation)
    MERGE (rightDownLocation:Location{posX:(x+1), posY:(y+1)})
    MERGE (location)-[:NEXT_TO]->(rightDownLocation)
    MERGE (leftDownLocation:Location{posX:(x-1), posY:(y+1)})
    MERGE (location)-[:NEXT_TO]->(leftDownLocation)
  )
)
WITH lines, linesCount, lineSize
// ^^ created all elements of the grid, a bit brute force
// now we need to delete elements without a seat, the last line and last column
MATCH (l:Location)
WHERE l.posY = linesCount OR l.posX = lineSize OR l.posX = -1 OR l.hasSeat = false
DETACH DELETE l;

// PART 1
// this is a bit crappy as I couldn't find a nice way to do a while loop
// so have to wait a bit for this to complete
CALL apoc.periodic.countdown("job", "
OPTIONAL MATCH (free:Location{occupied:false})
WHERE NOT exists( (free)--(:Location{occupied:true}) )
WITH collect(free) AS free
OPTIONAL MATCH (seat:Location{occupied:true})
WHERE size( (seat)--(:Location{occupied:true}) ) >= 4
WITH collect(seat) AS seat, free
FOREACH (f IN free | SET f.occupied=true)
FOREACH (s IN seat | SET s.occupied=false)
RETURN size(free) + size(seat) AS changed;
", 0);
MATCH(n{occupied:true}) RETURN count(n);

