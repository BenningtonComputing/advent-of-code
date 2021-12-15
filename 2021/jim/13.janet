``--- 13.janet ---------------------------------------
  https://adventofcode.com/2021/day/13

      $ time janet 13.janet 
      There are 17 example points after one fold.
      After example folds it looks like this:
      xmax=4, ymax=4
      #####
      #...#
      #...#
      #...#
      #####
      Day 13 Part 1 is 666
      xmax=38, ymax=5
      .##....##.#..#..##..####.#..#.#..#.#..#
      #..#....#.#..#.#..#....#.#..#.#.#..#..#
      #.......#.####.#..#...#..####.##...#..#
      #.......#.#..#.####..#...#..#.#.#..#..#
      #..#.#..#.#..#.#..#.#....#..#.#.#..#..#
      .##...##..#..#.#..#.####.#..#.#..#..##.

      real  0m0.017s
      user  0m0.012s
      sys   0m0.003s

   So the 8 letter code for part 2 is CJHAZHKU .
   Writing code to recognize that would be too much work. ;)

-------------------------------------------------------``
(use ./utils)

(defn get=number [line]
  (scan-number (get (string/split "=" (string/trim line)) 1)))
(assert (= (get=number "foo=43") 43) "check get=number")

(defn parse13 [text]
  (def points @[])
  (def folds @[])
  (loop [line :in (text->lines text)]
    (if (in? line "y=")
      (array/push folds [:y (get=number line)]))
    (if (in? line "x=")
      (array/push folds [:x (get=number line)]))
    (if (in? line ",")
      (array/push points (parse-comma-numbers line))))
  [points folds])

(def example-text (string/trim
``
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5``))

(def [example-points example-folds] (parse13 example-text))
#(printf "example points are %j" example-points)
#(printf "example follds are %j" example-folds)

# (points are (x,y))
# fold at x=XX means that x > XX => XX - (x-XX)

(defn fold-point
  "return new [x' y'] after folding along direction :x or :y at given value"
  [direction value [x y]]
  (case direction
    :x [(if (> x value) (- value (- x value)) x)
	y]
    :y [x
	(if (> y value) (- value (- y value)) y)]))

(assert (= (fold-point :y 7 [0 13]) [0 1]) "check fold-point")

(defn fold-points [direction value points]
  #(printf "points is %j" points)
  #(printf "direction is %j" direction)
  #(printf "value is %j" value)
  (map (fn [p]
	 #(printf "fn: p is %j" p)
	 (fold-point direction value p))
       points))

(defn foldem [points folds]
  (var pts (tuple ;points))
  (loop [[direction value] :in folds]
    (set pts (fold-points direction value pts)))
  (unique pts))

(defn count-first-fold [points folds]
  (def [direction value] (first folds))
  #(printf "first-fold direction=%j value=%j" direction value)
  (def new-points (fold-points direction value points))
  (length (unique new-points)))

(defn print-points [points]
  (def xmax (max ;(seq [[x y] :in points] x)))
  (def ymax (max ;(seq [[x y] :in points] y)))
  (printf "xmax=%j, ymax=%j" xmax ymax)
  (def grid (seq [:repeat (inc ymax)] (seq [:repeat (inc xmax)] (chr "."))))
  (loop [[x y] :in points]
    (.put grid [y x] (chr "#")))
  (loop [row :in grid]
    (print (string/from-bytes ;row))))

#(printf "example-points are %j" example-points)
#(printf "example-folds are %j" example-folds)
(printf "There are %j example points after one fold."
	(count-first-fold example-points example-folds))
(printf "After example folds it looks like this:")
(def example-folded (foldem example-points example-folds))
(print-points example-folded)

(def day13-points-folds (parse13 (slurp-input 13)))
(printf "Day 13 Part 1 is %j" (count-first-fold ;day13-points-folds))
#(pp day13-points-folds)
(def day13-folded (foldem ;day13-points-folds))
#(pp day13-folded)
(print-points day13-folded)
