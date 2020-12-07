WITH 'light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.' as input
UNWIND split(input, "\n") as line
WITH apoc.text.regexGroups(line, "([0-9]+)? ?([a-z ]+) bags?") as groups
WITH head(groups) as parent, tail(groups) as children
UNWIND children as child
MERGE (p:Bag{type:parent[2]})
MERGE (c:Bag{type:child[2]})
MERGE (p)-[:CAN_CONTAIN{qty:toInteger(child[1])}]->(c);

// PART 1
MATCH (b:Bag{type:'shiny gold'})<-[:CAN_CONTAIN*]-(parent)
RETURN count(DISTINCT parent);

// PART 2
MATCH p=(b:Bag{type:'shiny gold'})-[:CAN_CONTAIN*]->(child)
WITH child, reduce(cnt = 1, rel IN relationships(p) | cnt * rel.qty) as total
RETURN sum(total)