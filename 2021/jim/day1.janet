"--- day1.janet ---------------------------------------

  puzzle : https://adventofcode.com/2021/day/1

  $ janet day1.janet
  Day 1 Part 1 : 1266 increases.
  Day 1 Part 2 : 1217 increases in sums of triples.

  Took me 30 min.
-------------------------------------------------------"
(import* "./utils" :prefix "")       

(def day1 (lines->numbers (slurp-input 1)))

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




