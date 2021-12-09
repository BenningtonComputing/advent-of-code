``--- 9.janet ---------------------------------------
  https://adventofcode.com/2021/day/9

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

(defn add-border [grid]
  (def n (length (grid 0)))
  (def n2 (+ 2 n))
  (def edge 9)
  (def result @[ (array/new-filled n2 edge) ])
  (loop [line :in grid]
    (array/push result (array/concat @[edge] ;line edge)))
  (array/push result (array/new-filled n2 edge))
  result)

(def example-grid (add-border (text->grid example-text)))
(def day9-grid (add-border (text->grid day9-text)))

#(print "--- example grid with border of 9's ---")
#(print (grid->string example-grid))

(defn .get [grid [row col]] (get-in grid [row col]))
(defn .add "2d vector addition" [[row1 col1] [row2 col2]]
  [(+ row1 row2) (+ col1 col2)])
  
(def directions [[1 0] [0 1] [-1 0] [0 -1]])  # right down left up on grid
(defn neighbors "4 neighbor points" [p] (map |(.add $ p) directions))

(defn .left [grid] 1)                        # index of left range in border
(defn .right [grid] (dec (length (grid 0)))) # index of right range ditto
(defn .top [grid] 1)
(defn .bottom [grid] (dec (length grid)))

(defn low? "is point lower than neighbors?" [grid point]
  (def height (.get grid point))
  (all (fn [neighbor] (< height (.get grid neighbor)))
       (neighbors point)))

(defn risk "return risk value for given point" [grid point]
  (if (low? grid point)
    (+ 1 (.get grid point))
    0))

(defn grid-map
  "apply (func grid [row col]) to each point; return array of results"
  [func grid]
  (def result @[])
  (loop [row :range [(.top grid) (.bottom grid)]]
    (loop [col :range [(.left grid) (.right grid)]]
      (array/push result (func grid [row col]))))
  result)

(defn total-risk [grid] (+ ;(grid-map |(risk $0 $1) grid)))

#test grid-map with identiy function : pull out given point
#(printf "%j" (grid-map (fn [grid point] (.get grid point)) example-grid))

#test low values
#(printf "%j" (grid-map (fn [grid point] [point (low? grid point)]) example-grid))

#(printf "risks on example grid: %j" (grid-map |(risk $0 $1) example-grid))
(printf "total risk for example grid is %j" (total-risk example-grid))

(printf "Day 9 Part 1 is %j" (total-risk day9-grid))

# --------




