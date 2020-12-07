MATCH(n) DETACH DELETE n;
CREATE INDEX IF NOT EXISTS FOR (l:Location) ON (l.posY);

WITH '..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#' as input
WITH split(input, "\n") as lines
WITH lines, size(lines[0]) as lineSize, size(lines) as linesCount
FOREACH (y IN range(0, linesCount-1)|
  FOREACH (x IN range(0, lineSize-1)|
    MERGE (location:Location{posX:x, posY:y, hasTree:substring(lines[y], x, 1)='#'})
    MERGE (rightLocation:Location{posX:(x+1)%lineSize, posY:y, hasTree:substring(lines[y], (x+1)%lineSize, 1)='#'})
    MERGE (location)-[:NEXT_RIGHT]->(rightLocation)
    MERGE (downLocation:Location{posX:x, posY:(y+1), hasTree:substring(coalesce(lines[(y+1)],""), x, 1)='#'})
    MERGE (location)-[:NEXT_DOWN]->(downLocation)
  )
)
WITH lines, linesCount
// last line should be deleted
MATCH (l:Location{posY:linesCount})
DETACH DELETE l;

// PART 1
MATCH (n:Location)
WITH max(DISTINCT n.posY) as lastLine
MATCH (endNode:Location{posY: lastLine})
WITH collect(endNode) as endNodes
MATCH (start:Location {posX: 0, posY: 0})
CALL apoc.path.expandConfig(start, {
  relationshipFilter: "NEXT_RIGHT>,NEXT_RIGHT>,NEXT_RIGHT>,NEXT_DOWN>",
  terminatorNodes: endNodes
}) YIELD path
WITH nodes(path) as nodes
// keep only one landing nodes
WITH [i IN range(0, size(nodes)-1) WHERE i%4 = 0 | nodes[i].hasTree] as hasTreeList
UNWIND hasTreeList as hasTree
WITH hasTree WHERE hasTree = true
RETURN count(*)

// PART 2
MATCH (n:Location)
WITH max(DISTINCT n.posY) as lastLine
MATCH (endNode:Location{posY: lastLine})
WITH collect(endNode) as endNodes
MATCH (start:Location {posX: 0, posY: 0})
UNWIND [
  ["NEXT_RIGHT>","NEXT_DOWN>"],
  ["NEXT_RIGHT>","NEXT_RIGHT>","NEXT_RIGHT>","NEXT_DOWN>"],
  ["NEXT_RIGHT>","NEXT_RIGHT>","NEXT_RIGHT>","NEXT_RIGHT>","NEXT_RIGHT>","NEXT_DOWN>"],
  ["NEXT_RIGHT>","NEXT_RIGHT>","NEXT_RIGHT>","NEXT_RIGHT>","NEXT_RIGHT>","NEXT_RIGHT>","NEXT_RIGHT>","NEXT_DOWN>"],
  ["NEXT_RIGHT>","NEXT_DOWN>","NEXT_DOWN>"]
] as traversal
CALL apoc.path.expandConfig(start, {
  relationshipFilter: apoc.text.join(traversal, ','),
  terminatorNodes: endNodes
}) YIELD path
WITH traversal, nodes(path) as nodes
WITH traversal, [i IN range(0, size(nodes)-1) WHERE i % size(traversal) = 0 | nodes[i].hasTree] as hasTreeList
WITH reduce(count = 0, hasTree IN hasTreeList | CASE WHEN hasTree THEN count + 1 ELSE count END) as values
RETURN reduce(value = 1, v IN values | value * v)
