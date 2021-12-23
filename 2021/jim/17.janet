``--- 17.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/17

-------------------------------------------------------``
(use ./utils)

(defn text17->grid [text]
  (def text1  (string/replace-all "#" "1" text))
  (def text01 (string/replace-all "." "0" text1))
  (text->grid text01))

(defn grid->spacetable [grid]
  (def space @{})
  (loop [y :in (indices grid)
	 x :in (indices (grid 0))]
    (if (= 1 (.get grid [y x]))
      (put space [x y 0] 1)))
  space)

(defn .+ "3D vector addition"
  [[x0 y0 z0] [x1 y1 z1]]
  [(+ x0 x1) (+ y0 y1) (+ z0 z1)])

(def _neighbors @{})  # { cube [neighboring 26 cubes] }
(defn neighbors [cube]
  (if (not (in? _neighbors cube))
    (put _neighbors cube (seq [x :range-to [-1 1]
				y :range-to [-1 1]
				z :range-to [-1 1]
				:when (not= x y z 0)]
			       (.+ [x y z] cube))))
  (_neighbors cube))
(assert (= 26 (length (neighbors [0 0 0]))) "26 neighbors")
(defn neighbors-and-me [cube]
  (array/concat @[cube] (neighbors cube)))
(assert (= 27 (length (neighbors-and-me [0 0 0]))) "27 neighbors-and-me")

(defn count-active-neighbors [space cube]
  (+ ;(seq [nbr :in (neighbors cube)] (get space nbr 0))))

(defn step "one cycle forward to new state" [space]
  (def new-space @{})
  (loop [cube :in (distinct (mapcat neighbors-and-me (keys space)))]
    (def actives (count-active-neighbors space cube))
    (if (or (= 3 actives)
	    (and (= 2 actives) (= 1 (get space cube))))
      (put new-space cube 1)))
  new-space)

(defn steps "n cycles forward to new state" [space n]
  (if (zero? n)
    space
    (steps (step space) (dec n))))

(def example-grid (text->grid
 ``010
   001
   111``))
(print "-- example-grid --")
#(pp example-grid)
(print-grid-all example-grid)
(def example-space (grid->spacetable example-grid))
#(print "-- example-space --")
#(pp example-space)
#(printf "example's active neighbors of [2 2 0] : %j"
#	(count-active-neighbors example-space [2 2 0]))
(printf "example after 6 cycles has %j active"
	(length (steps example-space 6)))

(def day17-text (slurp-input 17))
(def day17-grid (text17->grid day17-text))
(def day17-space (grid->spacetable day17-grid))
(print)
#(print "-- day17-text")
#(print day17-text)
(print "-- day17-grid --")
(print-grid-all day17-grid)
(print)
(printf "Day 17 Part 1 is %j"
	(length (steps day17-space 6)))

