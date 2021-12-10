``--- 07.janet ---------------------------------------
  https://adventofcode.com/2021/day/7

      $ time janet 07.janet 
      day7 has 1000 numbers with (min,max) (0, 1881) : @[1101 1 29 ... 85 9 454]
      test has 10 numbers with (min,max) (0, 16) : @[16 1 2 0 4 2 7 1 2 14]
      min test fuel is 37 at position 2
      Part 1 : min day7 fuel is 355989 at position 344
      min test 2 fuel is 168 at position 5
      Part 2 : min day7 fuel is 102245489 at position 483

      real    0m0.474s
      user    0m0.452s
      sys     0m0.009s

-------------------------------------------------------``
(use ./utils)

# Get the data for day7 and its test case.

(def day7-numbers (parse-comma-numbers (slurp-input 7)))
(printf "day7 has %j numbers with (min,max) (%j, %j) : %q"
	(length day7-numbers) (min ;day7-numbers) (max ;day7-numbers)day7-numbers)

(def test-numbers (parse-comma-numbers "16,1,2,0,4,2,7,1,2,14"))
(printf "test has %j numbers with (min,max) (%j, %j) : %q"
	(length test-numbers) (min ;test-numbers) (max ;test-numbers) test-numbers)

(defn fuel
  "total fuel given array of numbers and position"
  [numbers position]
  (+ ;(map
       (fn [x] (math/abs (- x position)))
       numbers)))

#-- print fuel for all positions ; similar to text in puzzle --
#(for x (min ;test-numbers) (max ;test-numbers)
#  (printf "test fuel is %j at " (fuel test-numbers x) x))

(defn find-fuel-min
  " return [minimum-fuel at-position]"
  [numbers]
  # Look for the position with the minimal fuel.
  # The approach is to build a table of [position fuel],
  # then find the min fuel, then invert the table to get that position.
  (def x-fuel (map-table (fn [x] [x (fuel numbers x)])
			 (range (min ;numbers) (max ;numbers))))
  (def min-fuel (min ;(values x-fuel)))
  [min-fuel (get (invert x-fuel) min-fuel)])

(printf "min test fuel is %j at position %j"
	;(find-fuel-min test-numbers))

(printf "Part 1 : min day7 fuel is %j at position %j"
	;(find-fuel-min day7-numbers))

# -- part 2 ----------------
# The cost function has changed;
# now rather than diff=abs(x-position), we want (sum 1 to diff).
# The formula for that sum is (diff * (diff + 1))/2 ,
# so all we need is a slightly different fuel function.

(defn fuel2 [numbers position]
  "total fuel function for part 2"
  (+ ;(map
       (fn [x]
	 (let [diff (math/abs (- x position))]
	   (/ (* diff (inc diff)) 2)))
       numbers)))

(defn find-fuel-min2
  " return [minimum-fuel at-position] for part 2"  
  [numbers]
  (def x-fuel (map-table (fn [x] [x (fuel2 numbers x)])
			 (range (min ;numbers) (max ;numbers))))
  (def min-fuel (min ;(values x-fuel)))
  [min-fuel (get (invert x-fuel) min-fuel)])

(printf "min test 2 fuel is %j at position %j"
	;(find-fuel-min2 test-numbers))

(printf "Part 2 : min day7 fuel is %j at position %j"
	;(find-fuel-min2 day7-numbers))


