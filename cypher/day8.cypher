MATCH(n) DETACH DELETE n;

WITH 'nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6' as input
WITH split(input, "\n") as lines
UNWIND range(0, size(lines) - 2) as index
MERGE (current:Instruction {index: index})
  SET current.type=split(lines[index], " ")[0], current.value=toInteger(split(lines[index], " ")[1])
WITH current, (CASE current.type WHEN 'jmp' THEN current.index + current.value ELSE current.index + 1 END) as nextIndex
MERGE (next:Instruction {index: nextIndex})
MERGE (current)-[:NEXT]->(next);

// PART 1
MATCH p=(start:Instruction{index:0})-[:NEXT*]->(end)
WITH p ORDER BY length(p) DESC LIMIT 1
UNWIND nodes(p) as node
WITH node WHERE node.type = 'acc'
RETURN sum(node.value)

// PART 2
MATCH (i:Instruction{type:'nop'})
MATCH (maybeNext:Instruction{index:i.index + i.value})
WHERE NOT exists((i)--(maybeNext))
MERGE (i)-[:MAYBE_NEXT]->(maybeNext);

MATCH (i:Instruction{type:'jmp'})
MATCH (maybeNext:Instruction{index:i.index + 1})
WHERE NOT exists((i)--(maybeNext))
MERGE (i)-[:MAYBE_NEXT]->(maybeNext);

MATCH (n:Instruction)
WITH max(n.index) as lastIndexId
MATCH p=(start:Instruction{index:0})-[:NEXT*0..]->()-[:MAYBE_NEXT]->()-[:NEXT*0..]->(end:Instruction{index:lastIndexId})
UNWIND nodes(p) as node
WITH node WHERE node.type = 'acc'
RETURN sum(node.value)
