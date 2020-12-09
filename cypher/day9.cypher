MATCH(n) DETACH DELETE n;

WITH '35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576' as input
WITH split(input, "\n") as lines
UNWIND range(0, size(lines) - 2) as index
MERGE (current:Number {index: index, value:toInteger(lines[index])})
MERGE (next:Number {index: index + 1, value:toInteger(lines[index+1])})
MERGE (current)-[:NEXT]->(next);

// PART 1
// preamble size is 5 in this example but 25 on the full input
MATCH (n:Number)
WITH count(n) as numberCount
UNWIND range(5, numberCount - 1) as index
MATCH (n:Number{index:index})
MATCH (n1)-[:NEXT*1..5]->(n)
MATCH (n2)-[:NEXT*1..5]->(n)
WHERE n1 < n2
WITH n, collect(n1.value + n2.value) as sumsOfPairs
WITH n WHERE NOT n.value IN sumsOfPairs
RETURN n.value LIMIT 1

// PART 2
MATCH (n:Number)
WITH count(n) as numberCount
UNWIND range(5, numberCount - 1) as index
MATCH (n:Number{index:index})
MATCH (n1)-[:NEXT*1..5]->(n)
MATCH (n2)-[:NEXT*1..5]->(n)
WHERE n1 < n2
WITH n, collect(n1.value + n2.value) as sumsOfPairs
WITH n WHERE NOT n.value IN sumsOfPairs
WITH n.value as invalidNumber LIMIT 1
MATCH p=(n1:Number)-[:NEXT*]->(n2:Number)
WHERE reduce(sum = 0, node in nodes(p) | sum + node.value) = invalidNumber
UNWIND nodes(p) as node
RETURN min(node.value) + max(node.value)
