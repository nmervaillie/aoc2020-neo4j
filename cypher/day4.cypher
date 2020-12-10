WITH 'ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in' as input
WITH split(input, "\n\n") as passports
UNWIND passports as passport
WITH replace(passport, '\n', ' ') as passport
WHERE passport =~ '.*ecl:.+.*'
  AND passport =~ '.*pid:.+.*'
  AND passport =~ '.*eyr:.+.*'
  AND passport =~ '.*hcl:.+.*'
  AND passport =~ '.*byr:.+.*'
  AND passport =~ '.*iyr:.+.*'
  AND passport =~ '.*hgt:.+.*'
RETURN count(*)

// PART 2
WITH 'ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in' as input
WITH split(input, "\n\n") as passports
UNWIND passports as passport
WITH replace(passport, '\n', ' ') as passport
  WHERE passport =~ '.*\\becl:(amb|blu|brn|gry|grn|hzl|oth)\\b.*'
  AND passport =~ '.*\\bpid:[0-9]{9}\\b.*'
  AND passport =~ '.*\\beyr:(202[0-9]|2030)\\b.*'
  AND passport =~ '.*\\bhcl:#[0-9a-f]{6}\\b.*'
  AND passport =~ '.*\\bbyr:(19[2-9][0-9]|200[0-2])\\b.*'
  AND passport =~ '.*\\biyr:(201[0-9]|2020)\\b.*'
  AND passport =~ '.*\\bhgt:((1([5-8][0-9]|9[0-3])cm)|((59|6[0-9]|7[0-6])in))\\b.*'
RETURN count(*)