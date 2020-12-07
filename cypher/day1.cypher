WITH '1721
979
366
299
675
1456' as input
UNWIND split(input, "\n") as line
CREATE (e:Expense {amount:toInteger(line)});

// PART 1
MATCH (e1), (e2) WHERE e1<>e2 AND e1.amount + e2.amount = 2020
RETURN e1.amount * e2.amount;

// PART 2
MATCH (e1), (e2), (e3) WHERE e1<>e2<>e3 AND e1.amount + e2.amount + e3.amount = 2020
RETURN e1.amount * e2.amount * e3.amount;
