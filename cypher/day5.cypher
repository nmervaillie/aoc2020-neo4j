
WITH 'BFFFBBFRRR
FFFBBBFRRR
BBFFBBFRLL' as input
WITH split(input, "\n") as seats
UNWIND seats as seat
WITH apoc.text.regreplace(seat, '[B|R]', '1') as seat
WITH apoc.text.regreplace(seat, '[F|L]', '0') as seat
// seat id is just a binary representation of the seat string where B and R -> 1
// using bit shifting to convert binary string to integer - could not find a better way...
WITH reduce(seatId = 0, bit in split(seat, '') | apoc.bitwise.op(apoc.bitwise.op(seatId, '<<', 1), '|', toInteger(bit))) as seatId
WITH seatId ORDER BY seatId
WITH collect(seatId) as seatIds
UNWIND range(0, size(seatIds) - 2) as i
WITH seatIds, i WHERE seatIds[i+1] - seatIds[i] > 1
RETURN seatIds[i] + 1
