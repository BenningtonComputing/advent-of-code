``--- 09.janet ---------------------------------------
  https://adventofcode.com/2021/day/9

      $ time janet 09.janet 
      total risk for example grid is 15
      Day 9 Part 1 is 545
      largest three basins in example are (9 9 14)
      Day 9 Part 2 is 950600

      real  0m0.407s
      user  0m0.370s
      sys  0m0.020s

  Starting implementing some 2D vector and grid functions,
  put in ./utils.janet.

-------------------------------------------------------``
(use ./utils)

(def example-text
``2199943210
  3987894921
  9856789892
  8767896789
  9899965678``)

(def day9-text (slurp-input 9))

(defn text->grid [text] (map line->digits (text->lines text)))
(defn grid->string [grid]
  (def result @"")
  (loop [line :in grid]
    (loop [digit :in line]
      (buffer/push result (describe digit)))
    (buffer/push result "\n"))
  result)

(def example-grid (add-border (text->grid example-text) 9))
(def day9-grid (add-border (text->grid day9-text) 9))

#(print "--- example grid with border of 9's ---")
#(print (grid->string example-grid))

(defn low? "is point lower than neighbors?" [grid point]
  (def height (.get grid point))
  (all (fn [neighbor] (< height (.get grid neighbor)))
       (neighbors point)))

(defn risk "return risk value for given point" [grid point]
  (if (low? grid point)
    (+ 1 (.get grid point))
    0))

(defn total-risk [grid] (+ ;(grid-map |(risk $0 $1) grid)))

#test grid-map with identiy function : pull out given point
#(printf "%j" (grid-map (fn [grid point] (.get grid point)) example-grid))

#test low values
#(printf "%j" (grid-map (fn [grid point] [point (low? grid point)]) example-grid))

#(printf "risks on example grid: %j" (grid-map |(risk $0 $1) example-grid))
(printf "total risk for example grid is %j" (total-risk example-grid))

(printf "Day 9 Part 1 is %j" (total-risk day9-grid))

# --------

#(printf "%j" (zeros example-grid))

(defn lowest-neighbor [grid point]
  (def heights-positions @{})
  (loop [p :in (neighbors point)]
    (put heights-positions (.get grid p) p))
  (def low-point (min ;(keys heights-positions)))
  (heights-positions low-point))

(defn basins [grid]
  (def flows (grid-clone-fill grid 0))
  (loop [row :range [(.top grid) (.bottom grid)]]
    (loop [col :range [(.left grid) (.right grid)]]
      # visit each [row col] in grid
      (var here [row col])
      #(printf "looping; here is %j" here)
      (if-not (= (.get grid here) 9)       # do nothing if its a 9
	(do                                # otherwise, follow along to low
	  #(printf " (low? grid here) is %j" (low? grid here))
	  (while (not (low? grid here))
	    #(printf " here is %j ; (lowest-neighbor grid here) is %j" here (lowest-neighbor grid here))
	    (set here (lowest-neighbor grid here)))     # move to lowest neighbor
	  (.put flows here (inc (.get flows here)))))))  # at low point, add 1.
  flows)

(defn largest-three [grid]
  # slicing indices are weird : -4 to -1 is last three ... go figure.
  (slice (sort (flatten grid)) -4 -1))

(printf "largest three basins in example are %n" (largest-three (basins example-grid)))

(printf "Day 9 Part 2 is %j" (* ;(largest-three (basins day9-grid))))

