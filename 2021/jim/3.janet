``--- 3.janet ---------------------------------------
 https://adventofcode.com/2021/day/3

    $ janet 3.janet 
    The input for day3 starts with @["111110110111" "100111000111" "011101111101"].
    Number of lines is 1000.
    Length of a line is 12.
    -- test case --
    00100
    11110
    10110
    10111
    10101
    01111
    00111
    11100
    10000
    11001
    00010
    01010
    column 0 is 011110011100.
    -- test-case columns --
    011110011100
    010001010101
    111111110000
    011101100011
    000111100100
    (gamma 11000) is 0
    (gamma 1111000) is 1
    (epsilon 11000) is 1
    (epsilon 1111000) is 0
    gamma-rate test-case is 10110 
    epsilon-rate test-case is 01001 
    (base2 1101) is 13 (should be 13)
    product for test-case is 198 (should be 198)
    Day 3 Part 1 is 3969000

    oxy filter 0 is @["11110" "10110" "10111" "10101" "11100" "10000" "11001"]
    oxy filter 1 is @["10110" "10111" "10101" "10000"]
    oxy test-case is "10111"
    life-support for test-case is 230 (should be 230)
    Day 3 Part 2 is 4267809

I'm not particularly happy with my work on this one - the code feels
too awkward.  Janet's versions of strings and bytes is hard to wrap my
head around, without any character type. I should have converted the
ascii 0's and 1's to numeric 0's and 1's early on; perhaps that would
have made this feel cleaner.  And I hit a bug at the end in the logic
of my code, where for "least common" I was choosing a value with
frequency count of 0 (i.e. less than the other) and filtering out all
the lines ... Oops.
 
-------------------------------------------------------``
(import* "./utils" :prefix "")       

(def day3 (text->lines (slurp-input 3)))

(printf "The input for day3 starts with %j." (array/slice day3 0 3))
(printf "Number of lines is %j." (length day3))
(printf "Length of a line is %j." (length (day3 0)))

# OK, let's think of this data as an array :
#
#  012...  columns
#  ---------------
#  111110110111       0 ... lines
#  100111000111       1
#
# I can access this in janet as
#   ((day3 column) row)
# however, I'll get back 48 (ascii 0) or 49 (ascii 1).
# I can add that 48 or 49 to a mutable extendable string (a "buffer"),
# with (set ...) or (put ...) or (buffer/push-byte )
#
# And I can count things into a table with (frequencies indexed-data)
#
#  > (frequencies "1011")
#  @{48 1 49 3}           # byte 48 "0" happens 1 time, byte 49 "1" happens 3 times
#
# Here are some other string vs byte sequence operations :
#
#  > (string/bytes "101")
#  (48 49 48)
#
#  > (string/from-bytes 48 49 48)  # same as (string/from-bytes ;[48 49 48])
#  "101"

(def test-case (text->lines ``
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
``))

(defn print-grid [grid]
  (loop [i :in (indices grid)] (printf "  %s" (grid i))))

(print "-- test case --")
(print-grid test-case)

(defn column
  "return column c from number grid"
  [c numbers]
  (string/from-bytes
   ;(seq [i :in (indices numbers)] ((numbers i) c))))

(print "column 0 is " (column 0 test-case) ".")

(defn columns [numbers]
  (seq [c :in (indices (numbers 0))] (column c numbers)))

(print "-- test-case columns --")
(print-grid (columns test-case))

(def [zero one] [48 49])  # ascii byte constants for "0" and "1"

(defn gamma
  "given a binary word like '11000',
   return ascii byte 1 if there are more 1's, ascii byte 0 otherwise "
  [binary]
  (def counts (frequencies binary))
  (if (> (counts zero) (counts one)) zero one))

(defn epsilon
  "given a binary word like '11000',
   return ascii byte 1 if there are fewer 1's, ascii byte 0 otherwise "
  [binary]
  (def counts (frequencies binary))
  (if (< (counts zero) (counts one)) zero one))

(printf "(gamma 11000) is %c" (gamma "11000"))
(printf "(gamma 1111000) is %c" (gamma "1111000"))
(printf "(epsilon 11000) is %c" (epsilon "11000"))
(printf "(epsilon 1111000) is %c" (epsilon "1111000"))

(defn gamma-rate [numbers]
  (string/from-bytes ;(map gamma (columns numbers))))

(defn epsilon-rate [numbers]
  (string/from-bytes ;(map epsilon (columns numbers))))

(printf "gamma-rate test-case is %s " (gamma-rate test-case))
(printf "epsilon-rate test-case is %s " (epsilon-rate test-case))

(defn reverse-bits
  "convert e.g. '011' to [1 1 0] "
  # Note that (reverse "123") is @[51 50 49] i.e. ascii bytes.
  [str]
  (def zero-byte (chr "0"))
  (map (fn [x] (- x zero-byte)) (reverse str)))

(defn base2 [str]
  "convert binary string in base 2 to a number, e.g. '110' to 6"
  (var [result factor] [0 1])
  (loop [bit :in (reverse-bits str)]
    (+= result (* bit factor))    # bit is 0 or 1; factor is 1, 2, 4, 8, ...
    (*= factor 2))
  result)

(print "(base2 1101) is " (base2 "1101")
       " (should be 13)")

(defn gamma-epsilon-product [numbers]
  (* (base2 (epsilon-rate numbers))
     (base2 (gamma-rate numbers))))

(print "product for test-case is " (gamma-epsilon-product test-case)
       " (should be 198)")
(print "Day 3 Part 1 is " (gamma-epsilon-product day3))
(print)

# -------------------------------------------------------------

(defn oxy-filter
  "return subset of numbers, lines whose column matches "
  [numbers col]
  (def this-column (column col numbers))
  (def counts (frequencies this-column))
  (var which -1)
  (if (> (counts zero) (counts one))
    (set which zero)
    (set which one))
  # don't choose a value which isn't there :
  (if (not (counts zero)) (set which one))
  (if (not (counts one)) (set which zero))
  #(printf "   :::: oxyfilter counts=%j which=%j " counts which)
  (filter (fn [number] (= which (number col))) numbers))

(def oxy0 (oxy-filter test-case 0))
(printf "oxy filter 0 is %j" oxy0)

(def oxy1 (oxy-filter oxy0 1))
(printf "oxy filter 1 is %j" oxy1)

(defn oxy
  "return last remaining number after repeated oxy-filter"
  [numbers]
  (var nums (array ;numbers))
  (var col 0)
  (while (> (length nums) 1)
    (set nums (oxy-filter nums col))
    #(printf " --- OXY col=%j" col)
    #(print-grid nums)
    #(printf " --------------")
    (++ col))
  (nums 0))

(printf "oxy test-case is %j" (oxy test-case))

(defn co2-filter
  "return subset of numbers, lines whose column matches "
  [numbers col]
  (def this-column (column col numbers))
  (def counts (frequencies this-column))
  (var which -1)
  (if (> (counts zero) (counts one))
    (set which one)
    (set which zero))
  # don't choose a value which isn't there :
  (if (not (counts zero)) (set which one))
  (if (not (counts one)) (set which zero))
  (filter (fn [number] (= which (number col))) numbers))
  
(defn co2
  "return last remaining number after repeated co2-filter"
  [numbers]
  (var nums (array ;numbers))
  (var col 0)
  (while (> (length nums) 1)
    (set nums (co2-filter nums col))
    (++ col))
  (nums 0))

(defn life-support [numbers]
  (* (base2 (co2 numbers)) (base2 (oxy numbers))))

(printf "life-support for test-case is %j (should be 230)"
	(life-support test-case))

#(printf "co2 day3 is %j" (co2 day3))
#(printf "oxy day3 is %j" (oxy day3))

(printf "Day 3 Part 2 is %j" (life-support day3))

