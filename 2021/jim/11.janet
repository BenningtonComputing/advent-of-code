``--- 11.janet ---------------------------------------
  https://adventofcode.com/2021/day/11

      $ time janet 11.janet 
      example grid is 
      5483143223
      2745854711
      5264556173
      6141336146
      6357385478
      4167524645
      2176841721
      6882881134
      4846848554
      5283751526

      tiny example grid is 
      11111
      19991
      19191
      19991
      11111

      tiny example after one step
      34543
      40004
      50005
      40004
      34543

      tiny example after two steps
      45654
      51115
      61116
      51115
      45654

      after 10 steps, 204 flashes so far
      0481112976
      0031112009
      0041112504
      0081111406
      0099111306
      0093511233
      0442361130
      5532252350
      0532250600
      0032240000

      after 100 steps, 1656 flashes so far
      0397666866
      0749766918
      0053976933
      0004297822
      0004229892
      0053222877
      0532222966
      9322228966
      7922286866
      6789998766

      Day 11 Part 1 is 1688

      original example is
      5483143223
      2745854711
      5264556173
      6141336146
      6357385478
      4167524645
      2176841721
      6882881134
      4846848554
      5283751526

      Time when all of example flashes: 195

      Day 11 Part 2 is 403

      real  0m0.603s
      user  0m0.577s
      sys  0m0.019s

-------------------------------------------------------``
(use ./utils)

(def day11-grid-noborder (text->grid (slurp-input 11)))
(def day11-grid (add-border day11-grid-noborder 0))

(def example-grid-noborder (text->grid (string/trim
 ``5483143223
   2745854711
   5264556173
   6141336146
   6357385478
   4167524645
   2176841721
   6882881134
   4846848554
   5283751526 ``)))
(def example-grid (add-border example-grid-noborder 0))

(def tinyexample-grid-noborder (text->grid (string/trim
 ``11111
   19991
   19191
   19991
   11111``)))
(def tinyexample-grid (add-border tinyexample-grid-noborder 0))

(def example-grid-original (grid-clone example-grid))
(def day11-grid-original (grid-clone day11-grid))

(print "example grid is ")
(print-grid example-grid)

(print "tiny example grid is ")
(print-grid  tinyexample-grid)

# The border values will be incremented but not examined
# for flashing; they're just there to avoid special cases
# when looping over neighbors at the edges.

# All of these functions assume that the grid has a border.

# I'll mark a cell as "flashed already" by setting its value to 100;
# cells which are newly increased will be over 9 but under 100

(def flash-mark 100)

(defn point-increment "increment a point in grid" [grid point]
  (.put grid point (inc (.get grid point))))

(defn point-new-flash? "is a point over 9 and under flash-mark?" [grid point]
  (def energy (.get grid point))
  (and (> energy 9) (< energy flash-mark)))

(defn point-flashed? "is point over 9?" [grid point]
  (> (.get grid point) 9))

(defn grid-increment "increment each point in the grid" [grid]
  (grid-loop point-increment grid))

(defn grid-new-flash?
  "true if any points are over 9 and under flash-mark"
  [grid] (any identity (grid-map point-new-flash? grid)))

(defn neighbors-increment "add 1 to each neighbor of point" [grid point]
  (loop [neighbor :in (neighbors8 point)]
    (point-increment grid neighbor)))

(defn point-flash "if newly flashed, increment neighbors" [grid point]
  (if (point-new-flash? grid point)
    (do
      (.put grid point flash-mark)
      (neighbors-increment grid point))))

(defn grid-flash "flash each point in the grid" [grid]
  (grid-loop point-flash grid))

(defn point-reset "set a point to 0 if it was flashed" [grid point]
  (if (point-flashed? grid point) (.put grid point 0)))

(defn grid-reset "reset all points in the grid" [grid]
  (grid-loop point-reset grid))

(defn print-grid [grid] (print (inner-grid->string grid)))

(defn step "one step in octopus procedure" [grid]
  (grid-increment grid)
  (while (grid-new-flash? grid)
    (grid-flash grid))
  (grid-reset grid))

(defn count-flashes "return number of cells which flashed" [grid]
  (length (filter zero? (grid-map (fn [grd pt] (.get grd pt)) grid))))

(printf "tiny example after one step")
(step tinyexample-grid)
(print-grid tinyexample-grid)

(printf "tiny example after two steps")
(step tinyexample-grid)
(print-grid tinyexample-grid)

(var example-flashes 0)
(repeat 10
  (step example-grid)
  (+= example-flashes (count-flashes example-grid)))
(printf "after 10 steps, %j flashes so far" example-flashes)
(print-grid example-grid)

(repeat 90
	(step example-grid)
	(+= example-flashes (count-flashes example-grid)))
(printf "after 100 steps, %j flashes so far" example-flashes)
(print-grid example-grid)

(defn total-flashes [grid n-steps]
  (var counter 0)
  (repeat n-steps
	  (step grid)
	  (+= counter (count-flashes grid)))
  counter)

(defn all-flash-time [grid]
  (var time 0)
  (def all-of-grid (grid-size grid))
  (while true
    (++ time)
    (step grid)
    (if (= (count-flashes grid) all-of-grid) (break)))
  time)

(printf "Day 11 Part 1 is %j" (total-flashes day11-grid 100))
(print)

(def example (grid-clone example-grid-original))

(printf "original example is")
(print-grid example)

(printf "Time when all of example flashes: %j" (all-flash-time example))
(print)

(def day11 (grid-clone day11-grid-original))
(printf "Day 11 Part 2 is %j" (all-flash-time day11))

