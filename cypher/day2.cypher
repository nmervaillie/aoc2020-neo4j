WITH '1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc' as input
UNWIND split(input, "\n") as line
WITH apoc.text.regexGroups(line, "([0-9]+)-([0-9]+) (.+): (.*)") as groups
UNWIND groups as group
// PART 1
WITH toInteger(group[1]) as low, toInteger(group[2]) as high, group[3] as letter, group[4] as password
WHERE low <= size(split(password, letter))-1 <= high
RETURN count(*);

// PART 2
WITH toInteger(group[1]) as low, toInteger(group[2]) as high, group[3] as letter, group[4] as password
WITH password, letter, substring(password, low-1, 1) as ll, substring(password, high-1, 1) as hl
  WHERE ll STARTS WITH letter XOR hl STARTS WITH letter
// interestingly WHERE ll = letter does not work, not sure why
RETURN count(*)
