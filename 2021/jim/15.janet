``--- 15.janet ---------------------------------------
  https://adventofcode.com/2021/day/14

-------------------------------------------------------``
(use ./utils)

(def example-text 
``
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
``)

(defn text15->grid
  "convert text to grid with border"
  [text]
  (add-border (text->grid text) math/inf))

(def example-grid (text15->grid example-text))
#(pp example-grid)
(print "-- example grid --")
(print-grid-spacey example-grid)

# grid API from utils :
#  (.get grid [row col])
#  (.put grid [row col] value)
#  (shape grid) #[rows cols] size including border 

(defn .down  [[row col]] [(inc row) col])
(defn .up    [[row col]] [(dec row) col])
(defn .right [[row col]] [row (inc col)])
(defn .left  [[row col]] [row (dec col)])

(defn above? [[row1 col1] [row2 col2]] (= col1 col2))
(defn beside? [[row1 col1] [row2 col2]] (= row1 row2))

(defmacro go-down [grid point goal total]
  # defined with a macro rather than a function because of mutual recursion;
  # otherwise, min-path-1 needs to be already defined.
  ~(let [pt (.down ,point)
	ttl (+ ,total (.get ,grid pt))]
    (min-path-1 ,grid pt ,goal ttl)))

(defmacro go-right [grid point goal total]
  ~(let [pt (.right ,point)
	ttl (+ ,total (.get ,grid pt))]
    (min-path-1 ,grid pt ,goal ttl)))

# example: original     [[1 2 3] [4 5 6]]  # shape (2 3)
#          with border  [[9 9 9 9 9] [9 1 2 3 9] [9 4 5 6 9] [9 9 9 9 9]] # shape (4 5)
#                       top-right is (1 1) ; bottom left is (2 3) i.e. - 2 from shape

(defn top-left [grid] [1 1])                               # assumes border
(defn bot-right [grid] (point/subtract (shape grid) [2 2]))   # ditto

(defn min-path-1 [grid &opt point goal total]
  # 1st try: down or right, all branches
  (default point (top-left grid))
  (default goal (bot-right grid))
  (default total 0)
  (cond
    (= point goal) total
    (above? point goal) (go-down grid point goal total)
    (beside? point goal) (go-right grid point goal total)
    (min
     (go-down grid point goal total)
     (go-right grid point goal total))))

# This works. On a 10x10 example grid, tree is about 2**10 ~ 1000
#(printf "min-path-1 on example gives %j" (min-path-1 example-grid))

# but it's *much* too slow ...
# the input grid is 100x100 ; 2**100 is 1267650600228229401496703205376 .
#  (def day15-grid (add-border (text->grid (slurp-input 15)) 9))
#  (printf "Day 15 Part 1 is %j" (min-path-1 day15-grid))

# 2nd attempt: use the approach from the projecteuler pyramid;
# best out to each successive nested rectangle,
# adding in smallest of above vs left
#
#    0123
#    1123
#    2223
#    3333
#
#    025   in this order ; use the border to avoid thinking about edges
#    137
#    468
#

(defn min-at-point
  "add to grid point smaller of above & left point"
  [grid point]
  (.put grid point
	(+ (.get grid point)
	   (min (.get grid (.up point))
		(.get grid (.left point))))))

(defn minimize-grid
  "replace each grid point with smaller of above & left"
  # order is (a) by layers as per left array below,
  # then within each layer by the (b) pattern.
  #   (a)     (b)
  #  99999                       i j
  #  91234        2   layer 4 : (4 1) (1 4) (4 2) (2 4) (4 3) (3 4) (4 4)
  #  92234        4             1     2     3     4     5     6     7
  #  93334        6 
  #  94444     1357
  # Since we don't want to include the point at (1 1),
  # we need to (i) do the point at (2 2), then (ii) loop from row 3.
  [grid]
  (def new-grid (grid-clone grid))
  (min-at-point new-grid [2 2])
  (loop [i :range-to [3 (.bottom grid)]]
    (loop [j :range-to [1 i]]
      (min-at-point new-grid [i j])
      (if-not (= i j)
	(min-at-point new-grid [j i]))))
  new-grid)

(def minimized-example (minimize-grid example-grid))
#(print "-- minimized example --")
#(print-grid-spacey minimized-example)

(defn min-path-2
  "minimize, return bottom right value"
  [grid]
  (.get (minimize-grid grid) (bot-right grid)))

#(printf "min-path-2 on example gives %j"
#	(min-path-2 example-grid))

#(def day15-grid (text15->grid (slurp-input 15)))
#(printf "Day 15 Part 1 is %j"
#	(min-path-2 day15-grid))
# gave 531 ... which is incorrect.

# Let's try the same sort of approach
# but with a different order,
# going through successive diagonals , starting at (4 5 6) :
#
#    1 3 6 a . . .     The 4x4 case looks like this.
#    2 5 8 d . .       The . are entries outside; skip.
#    4 8 c f .
#    7 b e g
#    . . .
#    . .
#    .
#
# (1 1)
# (2 1) (1 2)
# (3 1) (2 2) (1 3)
# (4 1) (3 2) (2 3) (1 4)
#       (4 2) (3 3) (2 4)   # (5 1) is past edge; skip
#
# Hmmm. But suppose the best path isn't monotomically down or right?
# It isn't hard to come up with configurations with 1's along a twisty
# path and 9's elseshere. So this won't work either.
#
# I need to use Djikstra's and do a real "shortest-path" search,:
# extending a connected tree by *closest* which here means lowest total
# sum so far.  Neighbors are not just (down right) but also other
# directions.  Keep track of fringe (what we can get to on next step)
# and known (ones that we are sure we know the min distance.)

(defn shortest-path
  "Djikstra's shortest path search on a graph"
  # assumes grid has a border
  [grid]
  (def start (top-left grid))
  (def goal (bot-right grid))
  (var node start)
  (def known @{start 0})      # @{point value}
  (def fringe @{})            # @{point best-value-so-far}
  (def backpath @{})          # @{node parent ...}
  (while (not= node goal)
    (loop [neighbor :in (neighbors4-in-grid grid node)]
      #(printf "neighbor is %j; not in know is %j"
      #	      neighbor (not (in? known neighbor)))
      (if (not (in? known neighbor))
	(put fringe neighbor (min (get fringe neighbor math/inf)
				  (+ (known node) (.get grid neighbor))))))
    (def [new-node new-distance] (dict/find-min fringe))
    (if-not new-node (error "no path to goal"))
    (put known new-node new-distance)
    (put fringe new-node nil) # removing it
    (put backpath new-node node)
    #(printf "new-node is %j, distance is %j, parent is %j"
    # 	    new-node new-distance node)
    #(printf "fringe is %j" fringe)
    #(printf "known is %j" known) 
    (set node new-node))
  (known goal))

# 3rd different approach to solving this :
(printf "shortest-path example-grid is %j" (shortest-path example-grid))
(print)

(def day15-grid (text15->grid (slurp-input 15)))
(printf "Day 15 Part 1 is %j" (shortest-path day15-grid))
# ... and that is correct (in 1.8sec)

# If I need to speed up for part 2, the next step would be to
# implement a min-meap for the fringe to turn the O(n) search for
# smallest to O(1).

(defn text15->biggrid
  "convert text to 5x bigger grid, with border around whole thing"
  [text]
  (def original (text->grid text))
  )
  
  

