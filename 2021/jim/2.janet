``--- 2.janet ---------------------------------------
 https://adventofcode.com/2021/day/2
    $ janet 2.janet
    The input for day2 starts with @["forward 8" "forward 9" "forward 9" "down 3"].
    Number of lines is 1000.
    First line as step is (:forward 8).
    test case lines are
    @["forward 5" "down 5" "forward 8" "up 3" "down 8" "forward 2"]
    test case steps are
    @[(:forward 5) (:down 5) (:forward 8) (:up 3) (:down 8) (:forward 2)]
    move through test-steps to get (15 10)
    moving through all steps gives (2003 872)
    product is 1746616
    ... which is the right answer for Day 2 Part 1.
    new instructions for test case now gives (15 60 10)
    new method on all steps gives (2003 869681 872)
    product of position*depth is 1741971043
    ... which is the right answer for Day 2 Part 2.
-------------------------------------------------------``
(import* "./utils" :prefix "")       

(def day2 (text->lines (slurp-input 2)))

(printf "The input for day2 starts with %j." (array/slice day2 0 4))
(printf "Number of lines is %j." (length day2))

(defn line->step
  "convert strings like 'forward 20' to steps like [:forward 20] "
  [line]
  (def [direction distance] (string/split " " line))
  [(keyword direction) (parse distance)])

(printf "First line as step is %j." (line->step (first day2)))

(defn lines->steps [lines] (map line->step lines))

(def motions "functions for each type of step"
  {:forward (fn [[x z] distance] [(+ x distance) z])
   :down    (fn [[x z] distance] [x (+ z distance)])
   :up      (fn [[x z] distance] [x (- z distance)])})

(defn move
  "move through a sequence of steps and return final position"
  [steps]
  (var position [0 0])    # is [x z] i.e. [horizontal_position depth]
  (loop ([direction distance] :in steps)
    (set position ((motions direction) position distance)))
  position)

(def test-case ``
forward 5
down 5
forward 8
up 3
down 8
forward 2
``)

(printf "test case lines are ")
(def test-lines (text->lines test-case))
(pp test-lines)
(printf "test case steps are ")
(def test-steps (lines->steps test-lines))
(pp test-steps)
(printf "move through test-steps to get %j" (move test-steps))

(printf "moving through all steps gives %j" (move (lines->steps day2)))
(printf "product is %j" (* (splice (move (lines->steps day2)))))
(printf "... which is the right answer for Day 2 Part 1.")

# -------------------------------
# part 2 : new rules
#
# Our position is now [x z aim] , with three values.
# New formulas, but the same code structure.

(def motions2
  {:forward (fn [[x z aim] dist] [(+ x dist) (+ z (* dist aim)) aim])
   :down    (fn [[x z aim] dist] [x z (+ aim dist)])
   :up      (fn [[x z aim] dist] [x z (- aim dist)])})

(defn move2 [steps]
  (var position [0 0 0])   # is [x z aim]
  (loop ([direction distance] :in steps)
    (set position ((motions2 direction) position distance)))
  position)

(printf "new instructions for test case now gives %j"
	(move2 test-steps))

(def part2 (move2 (lines->steps day2)))
(printf "new method on all steps gives %j" part2)
(printf "product of position*depth is %j" (* (part2 0) (part2 1)))
(printf "... which is the right answer for Day 2 Part 2.")


