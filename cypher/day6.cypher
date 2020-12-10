WITH 'abc

a
b
c

ab
ac

a
a
a
a

b' as input
WITH split(input, "\n\n") as groups
UNWIND groups as group
CREATE (g:Group)
WITH g, split(group, '\n') as persons
UNWIND persons as personAnswers
CREATE (g)-[:HAS_PERSON]->(p:Person)
WITH g, p, personAnswers
UNWIND split(personAnswers, '') as answer
MERGE (a:Answer{value:answer})
CREATE (p)-[:ANSWERS]->(a);

// PART 1
MATCH (g:Group)--()--(a:Answer)
WITH g, count(distinct a) as countPerGroup
RETURN sum(countPerGroup);

// PART 2
MATCH (g:Group)--(persons)
WITH g, count(persons) as nbPersonsInGroup
MATCH (g)--(persons)--(a:Answer)
WITH nbPersonsInGroup, g, a, count(persons) as nbPersonsPerAnswer
  WHERE nbPersonsPerAnswer = nbPersonsInGroup
WITH g, count(distinct a) as countPerGroup
RETURN sum(countPerGroup);