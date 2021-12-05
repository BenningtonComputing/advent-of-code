``--- 5.janet ---------------------------------------
  https://adventofcode.com/2021/day/5

    $ time janet 5.janet
    Day 5 Part 1 is 4655.
    Day 5 Part 2 is 20500.
    real  0m2.361s

  Took me 2:20 ... but I'm happier this time with my use of the Janet
  language - starting maybe to get the hang of it. ;)

  And added several 2D point functions to utils.janet.

  One "gotcha" was when I used (mutable) arrays (2D points) as table
  keys.  Unlike python, janet lets you do this, but each distinct
  array is a distinct key, even if they print the same ... which is
  not at all what I wanted. Changing the points from @[x y] to [x y]
  fixed this somewhat subtle bug.

  For this problem, I was able to anticipate the part 2 variation and
  so wrote the part 1 code in a way that didn't much alteration to
  produce the part 2 answer.

-------------------------------------------------------``
(use ./utils spork)

#   The input looks like this :
#   976,35 -> 24,987
#   552,172 -> 870,490
#   647,640 -> 841,834
#   ...

(def test-text
  ``0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2``)

(defn parse-line
  " return 'vent' as table @{:x1 num :y1 num :x2 :y2 num} "
  [line]
  (table
   ;(interleave
     [:x1 :y1 :x2 :y2]
     (map scan-number (regex/match ``\s*(\d+),(\d+)\s+->\s+(\d+),(\d+)`` line)))))

(assert (deep= (parse-line "0,9 -> 5,9")
	       @{:x1 0 :y1 9 :x2 5 :y2 9}) "check parse-line")

(defn parse-text
  " return array of vents "
  [text]
  (map parse-line (text->lines text)))

(def test-vents (parse-text test-text))

(assert (deep= (last test-vents)
	       @{:x1 5 :y1 5 :x2 8 :y2 2}) "check parse-text & test-vents")

(defn hv?
  "horzontal or vertical ?"
  [{:x1 x1 :y1 y1 :x2 x2 :y2 y2}]  # destructuring function argument (!)
  (or (= x1 x2) (= y1 y2)))
(assert (     hv? {:x1 0 :y1 1 :x2 0 :y1 10})  "check hv?")
(assert (not (hv? {:x1 0 :y1 1 :x2 5 :y1 10})) "check not hv?")

# Should be 6 of test-vents that are horizontal or vertical.
(assert (= 6 (length (filter hv? test-vents))) "check test-vents")

(defn vent->coords
  "given a vent line segment, return an array of the (x y) coords it covers"
  # calculated as (x1 y1)+(dx dy)*factor, where factor is (0 1 2 3 ...)
  [{:x1 x1 :y1 y1 :x2 x2 :y2 y2}]
  (def dxdy (subtract-2d [x2 y2] [x1 y1]))
  (def unit (map sign dxdy))  # (1 1) or (1 0) or ... depending on direction
  (def size (inc (max ;(map math/abs dxdy)))) # length of line segment
  (map (fn [i] (add-2d [x1 y1] (scale-2d i unit))) (range size)))

# vent->coords example :
#   vent is {:x1 5 :y1 5 :x2 8 :y2 2}
#   so [dx dy] is [3 -3]
#      length is 4, 
#      coords are [[5 5] [6 4] [7 3] [8 2]]
# Note that the coords are immutable tuples [x y], not mutable arrays @[x y];
# it turns out that matters when they're keys later on.
(assert (deep= (vent->coords @{:x1 5 :y1 5 :x2 8 :y2 2})
	       @[ [5 5] [6 4] [7 3] [8 2]]) "check vent->coords")

# To keep track of cells and crossings,
# rather than create a matrix, I'll use a table called "cells"
# with key=(x y) , value=crossings; default value 0.

(defn hv/vents->cells
  "return table @{ (x y) crossings ... } built from horizontal & vertical vents"
  # Note that the keys of this cells table need to be
  # immutable tuples, not mutable tables;
  # otherwise, two coords may print the same but not be the same key.
  [vents]
  (def cells @{})
  (loop [vent :in (filter hv? vents)]
    #(printf " vent %j " vent)
    (loop [coord :in (vent->coords vent)]
      #(printf "    coord %j " coord)
      (put cells coord
	   (+ 1 (get cells coord 0)))))  # default 0 if coord not in cells yet
  cells)

# (pp (frequencies (values (hv/vents->cells test-vents)))) # => @{1 16 2 5}

(defn count-overlaps
  " return number of cells with values larger than 1 "
  [cells]
  (def freqs (frequencies (values cells))) # i.e. @{1 count1 2 count2 3 count3 ...}
  (put freqs 1 nil)     # delete (freqs 1), the cells that don't overlap
  (+ ;(values freqs)))  # return sum of other counts

(assert (= 5 (count-overlaps (hv/vents->cells test-vents)))
	"Test case : 5 overlapping cells in using horizontal/vertical only")

(def day5-vents (parse-text (slurp-input 5)))
(printf "Day 5 Part 1 is %j." (count-overlaps (hv/vents->cells day5-vents)))

(defn vents->cells
  "return table @{ (x y) crossings ... } built from all vents"
  # same as hv/vents->cells but without the horizontal/vertical filter
  [vents]
  (def cells @{})
  (loop [vent :in vents]
    (loop [coord :in (vent->coords vent)]
      (put cells coord
	   (+ 1 (get cells coord 0)))))
  cells)

(assert (= 12 (count-overlaps (vents->cells test-vents)))
	"Test case : 12 overlapping cells in total.")

(printf "Day 5 Part 2 is %j." (count-overlaps (vents->cells day5-vents)))
