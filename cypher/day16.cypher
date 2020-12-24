WITH 'class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12' as input
WITH split(input, '\n\n') as blocks
WITH blocks[0] as fields, split(blocks[1], '\n')[1] as ticket, split(blocks[2], '\n')[1..] as nearbyTickets
CREATE (mine:MyTicket{values:split(ticket, ',')})
WITH fields, nearbyTickets
UNWIND split(fields, '\n') as field
WITH apoc.text.regexGroups(field, "([a-z ]+): (\\d+)-(\\d+) or (\\d+)-(\\d+)") as groups, nearbyTickets
CREATE (f:Field {name:groups[0][1]})
CREATE (r1:Range {low:toInteger(groups[0][2]), high:toInteger(groups[0][3])})
CREATE (r2:Range {low:toInteger(groups[0][4]), high:toInteger(groups[0][5])})
CREATE (f)-[:HAS_RANGE]->(r1)
CREATE (f)-[:HAS_RANGE]->(r2)
WITH DISTINCT nearbyTickets
UNWIND nearbyTickets as nearbyTicket
CREATE (t:Ticket)
WITH t, split(nearbyTicket, ',') as values
UNWIND range(0, size(values) - 1) as pos
CREATE (v:FieldValue{position:pos, value:toInteger(values[pos])})
CREATE (t)-[:HAS_VALUE]->(v);

MATCH (v:FieldValue)
MATCH (r:Range) WHERE r.low <= v.value <= r.high
CREATE (v)-[:IS_IN_RANGE]->(r);

// PART 1
MATCH (v:FieldValue)
WHERE NOT exists( (v)-[:IS_IN_RANGE]->() )
RETURN sum(v.value);

// PART 2
// convert my ticket values from strings to longs
MATCH (mine:MyTicket)
UNWIND mine.values as value
WITH mine, collect(toInteger(value)) as values
SET mine.values = values;

// mark invalid tickets
MATCH (t:Ticket)--(v:FieldValue)
WHERE NOT exists( (v)-[:IS_IN_RANGE]->() )
SET t:Invalid;

// compute possible valid positions for each field
MATCH (t:Ticket)
  WHERE NOT t:Invalid
MATCH (t)--(v:FieldValue)
WITH v.position AS pos, collect(v) as valuesForPosition
MATCH (f:Field)
  WHERE all(value IN valuesForPosition WHERE exists((value)--(:Range)--(f)))
WITH f, collect(pos) as validPositions
SET f.validPositions = validPositions

// as a field can have several valid positions, iterate through fields starting with field having 1 possibility only
MATCH (f:Field)
WITH f ORDER BY size(f.validPositions) LIMIT 1
SET f.validPosition = f.validPositions[0];

// then continue and filter out already taken positions
CALL apoc.periodic.iterate(
"MATCH (f:Field) WHERE NOT exists(f.validPosition) RETURN f ORDER BY size(f.validPositions)",
"MATCH (o:Field) WHERE exists(o.validPosition)
WITH f, collect(o.validPosition) as takenPositions
SET f.validPosition = apoc.coll.removeAll(f.validPositions, takenPositions)[0]",
{batchMode: "SINGLE"}
);

// finally compute result
MATCH (f:Field)
WHERE f.name STARTS WITH 'departure'
WITH collect(f.validPosition) as positions
MATCH (t:MyTicket)
RETURN reduce(result = 1, pos IN positions | result * t.values[pos])


// ALTERNATIVE - this is also a valid full in memory solution for part 1

WITH 'class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12' as input
WITH split(input, '\n\n') as blocks
WITH blocks[0] as fields, split(blocks[1], '\n')[1] as ticket, split(blocks[2], '\n')[1..] as nearbyTickets
UNWIND split(fields, '\n') as field
WITH apoc.text.regexGroups(field, "([a-z]+): (\\d+)-(\\d+) or (\\d+)-(\\d+)") as groups, nearbyTickets
WITH range(toInteger(groups[0][2]), toInteger(groups[0][3])) as r1, range(toInteger(groups[0][4]), toInteger(groups[0][5])) as r2, nearbyTickets
WITH apoc.coll.flatten(collect(r1+r2)) as validValues, nearbyTickets
WITH split(apoc.text.join(nearbyTickets, ','), ',') as values, validValues
UNWIND values as value
WITH toInteger(value) as value, validValues
  WHERE NOT value IN validValues
RETURN sum(value)

