``--- 14.janet ---------------------------------------
  https://adventofcode.com/2021/day/14

-------------------------------------------------------``
(use ./utils)

(def example-text 
``
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
``)

(defn parse14
  "return @{:template bytes :rules @{bytes byte ...}}"
  [text]
  (def lines (text->lines text))
  (def state @{})
  (put state :template (array ;(string/bytes (lines 0))))
  (put state :original-template (array ;(state :template)))
  (put state :rules @{})
  (loop [ruleline :in (slice lines 1 -1)]
    (def [left right] (string/split " -> " ruleline))
    (def rule-key (string/bytes left))             # e.g. "CH => (67 72) 
    (def rule-value (first (string/bytes right)))
    #(printf "%j:%j => key=%j, value=%j" left right rule-key rule-value)
    (put (state :rules) rule-key rule-value))
  state)

(defn reset "restore state to its original template" [state]
  (put state :template (array ;(state :original-template))))

#(pp (parse14 example-text))
#(pp (parse14 day14-text))

(defn step "modify state template by one step" [state]
  (var i 0) # array index into (state :template)
  (while (< i (dec (length (state :template))))
    (def pair [(get (state :template) i)
	       (get (state :template) (inc i))])
    (def insert (get (state :rules) pair))
    #(printf "  STEPPING : template is %s" (string/from-bytes ;(state :template)))
    #(printf "             i=%j, pair=%j, insert=%j" i pair insert)
    (if insert (do
		 (++ i)
		 (array/insert (state :template) i insert)))
    (++ i)))

(defn most-least
  "return most common - least common after given number of steps"
  [state steps]
  (var stepnumber 0)
  (repeat steps
	  (++ stepnumber)
	  (step state))
	  #(printf " step %j length is %j" stepnumber (length (state :template))))
  (def freqs (values (frequencies (state :template))))
  (- (max ;freqs) (min ;freqs)))

(def example-state (parse14 example-text))

(printf "template:     %s"
	(string/from-bytes ;(example-state :template)))
(loop [step-number :range-to [1 4]]
  (step example-state)
  (printf "after step %j: %s"
	  step-number (string/from-bytes ;(example-state :template))))

(reset example-state)

#(printf "number of rules: %j" (length (example-state :rules)))
#(printf "template:     %s" (string/from-bytes ;(example-state :template)))
(printf "After 10 steps, most - least in example is %j"
	(most-least example-state 10))

(def day14-state (parse14 (slurp-input 14)))
(printf "Day 14 Part 1 is %j" (most-least day14-state 10))

(reset example-state)
(reset day14-state)

#(printf "After 40 steps, most - least in example is %j"
#	(most-least example-state 40))

#(printf "Day 14 Part 2 is %j" (most-least day14-state 40))

# This is too slow - the strings are getting too long.
# Just the numbers in the example make it clear that
# this is going to overflow memory.
#
# working on 40 steps in example :
#
# step 1 length is 7
# step 2 length is 13
# step 3 length is 25
# step 4 length is 49
# step 5 length is 97
# step 6 length is 193
# step 7 length is 385
# step 8 length is 769
# step 9 length is 1537
# step 10 length is 3073
# step 11 length is 6145
# step 12 length is 12289
# step 13 length is 24577
# step 14 length is 49153
# step 15 length is 98305
# step 16 length is 196609
# step 17 length is 393217
# step 18 length is 786433
# step 19 length is 1572865

# --------------------------------
#
# New approach:
# Store pairs (consecutive letters) and count for each; not strings.
# So for example
#  "NNCB" would be { NN 1 NC 1 CB 1 }
# Then in each step, the rule NN -> C means that
# the pair NN becomes both NC and CN, each with the same count.
# And then we combine the counts in all those new pairs.

(defn polymerize "modify state by adding a :polymer table" [state]
  (put state :polymer @{})
  (var i 0)
  (while (< i (dec (length (state :template))))
    (def pair [(get (state :template) i)
	       (get (state :template) (inc i))])
    (put (state :polymer) pair
	 (inc (get (state :polymer) pair 0)))
    (++ i)))


(defn step-poly "modify polymer state by taking one step" [state]
  (def polymer (state :polymer))
  (def new-polymer @{})
  (loop [pair :in (keys polymer)]
    (def insert (get (state :rules) pair))
    (if insert
      (do
	(def left [(first pair) insert])
	(def right [insert (second pair)])
	(put new-polymer left (+ (get polymer pair)
				 (get new-polymer left 0)))
	(put new-polymer right (+ (get polymer pair)
				  (get new-polymer right 0))))
      (put new-polymer pair (+ (get polymer pair)
			       (get new-polymer pair 0)))))
  (put state :polymer new-polymer))

# Now I need to turn the counts of pairs
#  { NN:1 NC:1 CB:1 }
# into counts of single symbols.
# Note that the first symbol and last symbol don't change,
# so I can get them from the original.
# So for each pair:
#  increment (first pair) count
#  increment (second pair) count
# Then increment both (first original) and (last original) counts
# Finally divide each count by 2, since everything has been counted twice.

(defn freqs-from-poly [state]
  (def counts @{})
  (loop [pair :in (keys (state :polymer))]
    (def left (first pair))
    (def right (second pair))
    (def count (get (state :polymer) pair))
    (put counts left (+ count (get counts left 0)))
    (put counts right (+ count (get counts right 0))))
  (def first-symbol (first (state :template)))
  (def last-symbol (last (state :template)))
  (++ (counts (first (state :template))))
  (++ (counts (last (state :template))))
  (loop [symbol :in (keys counts)]
    (put counts symbol (/ (get counts symbol) 2)))
  counts)

(defn most-least-poly
  "return most common - least common after steps; polymer version"
  [state steps]
  (repeat steps (step-poly state))
  #(printf "poly state is %j" state)
  (def freqs (values (freqs-from-poly state)))
  #(printf "poly freqs are %j" freqs)
  (- (max ;freqs) (min ;freqs)))

(reset example-state)
(polymerize example-state)

#(printf "0th poly example is %j" (example-state :polymer))
#(step-poly example-state)
#(printf "1st poly example is %j" (example-state :polymer))
#(step-poly example-state)
#(printf "2nd poly example is %j" (example-state :polymer))
#(step-poly example-state)
#(printf "34d poly example is %j" (example-state :polymer))

(printf "Using new approach ...")
(printf "after 10 poly steps, most - least example is %j"
	(most-least-poly example-state 10))

(reset example-state)
(polymerize example-state)
(printf "after 40 poly steps, most - least example is %j"
	(most-least-poly example-state 40))

(reset day14-state)
(polymerize day14-state)
(printf "Day 14 Part 2 is %j"
	(most-least-poly day14-state 40))

