WITH '28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3' as input
WITH split(input, "\n") as lines
UNWIND lines as line
CREATE (a:Adapter{joltage:toInteger(line)});

// this one is interesting as there is a large number of possible paths in the user dataset
// it requires some small hacks for performance

// for performance reasons, the query here is a bit complicated
// as it just creates one relationship to the next adapter with smallest joltage
// see part 2 for more on this
MATCH (a:Adapter)
MATCH (other:Adapter) WHERE a.joltage < other.joltage <= (a.joltage + 3)
WITH a, other ORDER BY other.joltage
WITH a, head(collect(other)) as otherWithLowerJoltage
CREATE (a)-[:PLUGS_IN]->(otherWithLowerJoltage);

// Create charging outlet
MATCH (first:Adapter) WHERE NOT ()-->(first)
CREATE (start:ChargingOutlet{joltage:0})-[:PLUGS_IN]->(first);
// Create output device
MATCH (last:Adapter) WHERE NOT (last)-->()
CREATE (last)-[:PLUGS_IN]->(:Device{joltage:last.joltage+3});

// PART 1
MATCH p=(start:ChargingOutlet)-[:PLUGS_IN*]->(end:Device)
WITH nodes(p) as adapters
UNWIND range(0, size(adapters) - 2) as i
WITH adapters[i+1].joltage - adapters[i].joltage as diff
WITH diff, count(diff) as diffCount
WITH collect(diffCount) as diffCounts
RETURN reduce(result = 1, diffCount IN diffCounts | result * diffCount)

// PART 2
MATCH (n)-[r]-() DELETE r;
// this time we need to create all paths
MATCH (a)
MATCH (other) WHERE a.joltage < other.joltage <= (a.joltage + 3)
MERGE (a)-[:PLUGS_IN]->(other);

MATCH (start:ChargingOutlet) SET start.cumulativeCount = 1;

// this would be the native graph, easy way but does not work on larger volumes
// too many paths - query never completes
//MATCH (start:ChargingOutlet)-[:PLUGS_IN*]->(end:Device)
//RETURN count(*)

// iterate on each node and keep a state of possible path count to arrive there
// we can't use a simple query here, as we rely on the state set on a node previously

CALL apoc.periodic.iterate(
  "MATCH (n) RETURN n ORDER BY n.joltage",
  "MATCH (previous)-->(n) WITH n, sum(previous.cumulativeCount) as count SET n.cumulativeCount = count",
  {batchMode: "SINGLE"});
MATCH (last:Adapter) RETURN max(last.cumulativeCount);

// this alternative also works, although I'm not so sure if sub-queries could be executed in parallel
MATCH (n) WITH n ORDER BY n.joltage
CALL {
  WITH n
  MATCH (previous)-->(n) WITH n, sum(previous.cumulativeCount) as count SET n.cumulativeCount = count
  RETURN 1
}
RETURN max(n.cumulativeCount)