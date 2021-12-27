``--- 17.janet ---------------------------------------
  puzzle : https://adventofcode.com/2020/day/17

  Ooops ... I thought I was doing 2021 day 17
            but this is 2020 day 17. Go figure.

      $ time janet 17.janet 
      -- example-grid --
      010
      001
      111
      example after 6 cycles has 112 active

      -- day17-grid --
      00110101
      01111100
      10000011
      11011010
      00100010
      01001100
      01000101
      10011011

      Day 17 Part 1 is 213

      in 4D example after 6 cycles has 848 active

      Day 17 Part 2 is 1624

      real  0m25.955s
      user  0m25.870s
      sys   0m0.077s

The approach I'm using here (dictionaries to hold active cell
locations) is fairly slow (26sec) but was straightforward to 
code. I expect that looping explicitly over 4D tensors in memory
would be faster.

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

# --- part 2 : four dimensions -----------------

(defn grid->space4table [grid]
  (def space4 @{})
  (loop [y :in (indices grid)
	 x :in (indices (grid 0))]
    (if (= 1 (.get grid [y x]))
      (put space4 [x y 0 0] 1)))
  space4)

(defn .+4 "4D vector addition"
  [[x0 y0 z0 t0] [x1 y1 z1 t1]]
  [(+ x0 x1) (+ y0 y1) (+ z0 z1) (+ t0 t1)])

(def _neighbors4 @{})  # { hyper [neighboring 80 cubes] }
(defn neighbors4 [hyper]
  (if (not (in? _neighbors4 hyper))
    (put _neighbors4 hyper (seq [x :range-to [-1 1]
				 y :range-to [-1 1]
				 z :range-to [-1 1]
				 t :range-to [-1 1]
				:when (not= x y z t 0)]
				(.+4 [x y z t] hyper))))
  (_neighbors4 hyper))
(assert (= 80 (length (neighbors4 [0 0 0 0]))) "80 neighbors4")
(defn neighbors4-and-me [hyper]
  (array/concat @[hyper] (neighbors4 hyper)))
(assert (= 81 (length (neighbors4-and-me [0 0 0 0]))) "81 neighbors4-and-me")

(defn count-active-neighbors4 [space4 hyper]
  (+ ;(seq [nbr :in (neighbors4 hyper)] (get space4 nbr 0))))

(defn step4 "one cycle forward to new state in 4D" [space4]
  (def new-space4 @{})
  (loop [hyper :in (distinct (mapcat neighbors4-and-me (keys space4)))]
    (def actives (count-active-neighbors4 space4 hyper))
    (if (or (= 3 actives)
	    (and (= 2 actives) (= 1 (get space4 hyper))))
      (put new-space4 hyper 1)))
  new-space4)

(defn steps4 "n cycles forward to new state in 4D" [space4 n]
  (if (zero? n)
    space4
    (steps4 (step4 space4) (dec n))))

(def example-space4 (grid->space4table example-grid))
(print)
(printf "in 4D example after 6 cycles has %j active"
	(length (steps4 example-space4 6)))

(def day17-space4 (grid->space4table day17-grid))
(print)
(printf "Day 17 Part 2 is %j"
	(length (steps4 day17-space4 6)))
