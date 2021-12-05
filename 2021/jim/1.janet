"--- 1.janet ---------------------------------------

  puzzle : https://adventofcode.com/2021/day/1

    $ janet 1.janet
    The input for day1 is 2000 integers: @[171 173 174 163 161] ...
    Day 1 Part 1 : 1266 increases.
    Day 1 Part 2 : 1217 increases in sums of triples.

  My personal leaderborad stats page at 
  https://adventofcode.com/2021/leaderboard/self
  says that it took me 13:13 and 30:23 to submit
  the two parts, with ranks (how many people 
  submitted correct answers before me) of 572 and 624.
  
  But who's counting, eh? 🤨
-------------------------------------------------------"
(use ./utils)

(def day1 (map parse (text->lines (slurp-input 1))))
(printf "The input for day1 is %j integers: %j ..."
	(length day1) (array/slice day1 0 5))

# -- part 1 ----------------

(defn count-increases [values]
  " Return number of increases in a sequence of values. "
  (def ups " sequence of booleans, true if increase from value i to i+1 "
    (seq [i :in (range (- (length values) 1))]
	 (< (values i) (values (+ 1 i)))))
  (length (filter identity ups)))
  
(printf "Day 1 Part 1 : %j increases." (count-increases day1))

# -- part 2 ---------------------

(defn consecutive-triples [numbers]
  " Given [1 2 3 4] return [[1 2 3] [2 3 4]] "
  (seq [i :in (range (- (length numbers) 2))]
       [(numbers i) (numbers (+ 1 i)) (numbers (+ 2 i))]))
# test: forming consecutive triples
# (pp (consecutive-triples [1 2 3 4 5]))  # note: pp is "pretty print"
# gives @[(1 2 3) (2 3 4) (3 4 5)]

(defn sum-seqs [array-of-sequences]
  (map (fn [xs] (+ (splice xs))) array-of-sequences))
# note: The "splice" does e.g. (+ (splice [1 2 3])) => (+ 1 2 3)
# test: adding numbers in each triple
# (pp (sum-seqs (consecutive-triples [1 2 3 4 5])))
# gives @[6 9 12]

(printf "Day 1 Part 2 : %j increases in sums of triples."
	(count-increases (sum-seqs (consecutive-triples day1))))




