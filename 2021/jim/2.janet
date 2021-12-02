"--- 2.janet ---------------------------------------

  puzzle : https://adventofcode.com/2021/day/2

-------------------------------------------------------"
(import* "./utils" :prefix "")       

(def day2 (text->lines (slurp-input 2)))

(printf "The input for day2 starts with %j." (array/slice day2 0 4))
(printf "Number of lines is %j." (length day2))

(defn line->step [line]
  (def [direction distance] (string/split " " line))
  [(keyword direction) (parse distance)])

(printf "First line as step is %j." (line->step (first day2)))

(defn lines->steps [lines] (map line->step lines))

(def motions
  {:forward (fn [[x z] distance] [(+ x distance) z])
   :down    (fn [[x z] distance] [x (+ z distance)])
   :up      (fn [[x z] distance] [x (- z distance)])})

(defn move [steps]
  (var position [0 0])    # is [x z] i.e. [horizontal_position depth]
  (loop ([direction distance] :in steps)
    (set position ((motions direction) position distance)))
  position)

# ------------

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



