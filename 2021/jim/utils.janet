`` utils.janet

utility functions for advent of code 2021

Jim Mahoney |  cs.bennington.college | MIT License | Dec 2021
``

# --- input ---

(defn slurp-input "get input for day n" [n]
  (slurp (string/join ["./inputs/" (string n) ".txt"])))

(defn parse-comma-numbers
  "convert '1,2,3\n' to [1 2 3]"
  [text]
  (map scan-number (string/split "," (string/trim text))))

(defn text->lines
  "return array of non-empty lines from text"
  [text]
  (filter (fn [x] (> (length x) 0))
	  (string/split "\n" text)))

(defn collapse-space
  "convert multiple adjacent spaces to one space"
  [text]
  (peg/replace-all ~(some " ") " " text))
(assert (deep= (collapse-space "a  b  c") @"a b c"))

(defn filter-out-nil [values] (filter (fn [x] (not (nil? x))) values))

(defn line->numbers
  "line is numbers with any number of spaces between; return array of numbers"
  [line]
  (filter-out-nil (map scan-number (string/split " " (collapse-space line)))))
(deep= (line->numbers "1  2   3") @[1 2 3])

(defn text->grid
  " convert lines of text with spaces between numbers 
    to a grid (an array of arrays) of numbers "
  [text]
  (def lines (text->lines text))
  (map line->numbers lines))

(def test-text-grid ``
   1  2   3
  12 13 101
``)
(def test-grid (text->grid test-text-grid))
(assert (deep= test-grid @[@[1 2 3] @[12 13 101]]))

(defn string-delim->ints
  "split line into words on delim; convert words to numbers"
  [delim line]
  (map scan-number (string/split delim line)))

(defn string->ints
  "convert string of ints with space delimeter to array of integers"
  # Note that <scan-number> and <parse> do similar things, converting "1" to 1.
  # But <scan-number> returns nil if it can't find a number.
  [text]
  (map parse (string/split " " text)))

(defn file->ints
  "read in file of integer values, return as array of integers"
  [filename]
  (string->ints (slurp filename)))

(defn line->digits " '1234' -> [ 2 3 4] " [line]
  (def ascii0 (chr "0"))
  (tuple ;(map |(- $ ascii0) (string/bytes (string/trim line)))))
(assert (= (line->digits "123") [1 2 3]) "check line->numbers")

(defn text->grid [text] (map line->digits (text->lines text)))
(defn grid->string [grid]
  (def result @"")
  (loop [line :in grid]
    (loop [digit :in line]
      (buffer/push result (describe digit)))
    (buffer/push result "\n"))
  result)

(defn inner-grid->string [grid]
  "convert grid of numbers to printable string, leaving out border"
  (def result @"")
  (loop [line :in (slice grid 1 -2)]
    (loop [digit :in (slice line 1 -2)]
      (buffer/push result (describe digit)))
    (buffer/push result "\n"))
  result)

# --- data structures ---

(defn map-table
  " Given a function that produces [key value] pairs, collect into a table "
  # THIS IMPLEMENTATION IS BUGGY - flatten will change interior key/value stuff.
  # FIXME : change to an accumulator pattern, walking through pairs & updating 
  [func values]
  (table ;(flatten (map func values))))

(defn indices "indices of an array" [values] (range (length values)))
(assert (deep= (indices [4 5 6]) @[0 1 2]))

(defn array->pairs
  " Given an array [1 2 3], return array of all combos of two 
    distinct elements [[1 2] [1 3] [2 1] [2 3] [3 1] [3 2] "
  # This name is not the best; "pairs" means something else in janet.
  [values]
  (seq [x :in (indices values)
	y :in (indices values)
	:when (not (= x y))]
       [(values x) (values y)]))
(assert (deep= (array->pairs [1 2 3])
	       @[[1 2] [1 3] [2 1] [2 3] [3 1] [3 2]]))

(defn get2
  " return value at given row and column of 2d grid i.e. array of array "
  # But see get-in ; (get-in matrix [row col])
  # DEPRECATED - use .get below
  [grid row col]
  ((grid row) col))

(assert (= (get2 test-grid 1 0) 12)) # [[1 2 3] [12 13 101]]

(defn set2
  " set 2d grid (i.e. array of arrays) at (row,column) to given value"
  # But see (put-in ...) ; (put-in (matrix) [row col] value)
  # DEPRECATED - use .put below  
  [grid row col value]
  (set ((grid row) col) value))

(set2 test-grid 0 0 100)
(assert (= (get2 test-grid 0 0) 100))

# -- 2D vectors --

(defn .get [grid [row col]] (get-in grid [row col]))
(defn .put [grid [row col] value] (put-in grid [row col] value))

(defn .add "2d vector addition" [[row1 col1] [row2 col2]]
  [(+ row1 row2) (+ col1 col2)])
  
(def directions [[1 0] [0 1] [-1 0] [0 -1]])  # right down left up on grid
(defn neighbors "4 neighbor points" [p] (map |(.add $ p) directions))

(def directions8 [[-1 -1] [-1 0] [-1 1]
		  [ 0 -1]        [ 0 1]
                  [ 1 -1] [ 1 0] [ 1 1]])
		  
(defn neighbors8 "8 neighbor points" [p] (map |(.add $ p) directions8))

(defn add-border
  "given a rectangular grid, add a border with given edge value"
  [grid edge]
  (def n (length (grid 0)))
  (def n2 (+ 2 n))
  (def result @[ (array/new-filled n2 edge) ])
  (loop [line :in grid]
    (array/push result (array/concat @[edge] ;line edge)))
  (array/push result (array/new-filled n2 edge))
  result)

# extremes of grid for looping ; assumes it has a border
(defn .left [grid] 1)                        # index of left range in border
(defn .right [grid] (dec (length (grid 0)))) # index of right range ditto
(defn .top [grid] 1)
(defn .bottom [grid] (dec (length grid)))

(defn grid-map
  "apply (func grid [row col]) to points inside border; return result array"
  # assumes grid has a border; does not apply func to border values.
  [func grid]
  (def result @[])
  (loop [row :range [(.top grid) (.bottom grid)]]
    (loop [col :range [(.left grid) (.right grid)]]
      (array/push result (func grid [row col]))))
  result)

(defn grid-loop
  "apply (func grid [row col]) to each point inside border."
  [func grid]
  (loop [row :range [(.top grid) (.bottom grid)]]
    (loop [col :range [(.left grid) (.right grid)]]
      (func grid [row col]))))

(defn grid-size "width*heigh size not including border" [grid]
  (* (- (length grid) 2) (- (length (grid 0)) 2)))

(defn print-grid [grid] (print (inner-grid->string grid)))

(defn grid-clone-fill [grid value]
  "create a new grid, same shape as given one, filled with given value"
  (def width (length (grid 0)))
  (def height (length grid))
  (map (fn [i] (array/new-filled width value)) (range height)))

(defn grid-clone [grid]
  (seq [row :in grid] (array ;row)))

# -- misc --

(defn any
  " return true if any of (predicate value), else return false "
  # But see (truthy? x) and (any? pred vals)
  # ...better written as (truthy? (any? predicate values))
  [predicate values]
  (if (some predicate values)
    true
    false))

(defn in?
  " true if x is in items "
  # Also see (find predicate items &opt default)
  [x items]
  (not (nil? (index-of x items))))

(defn sign
  "1, 0, -1 for positive, zero, negative"
  # Also see (cmp x y) which is similar.
  [x]
  (cond (< x 0) -1
	(> x 0)  1
	         0))

(defn table->stringy
  " turn table into '<table key:value key:value>"
  [t]
  (def result @"<table ")
  (loop [[key value] :pairs t]
    (loop [s :in
	     [(describe key) ":" (describe value) " "]]
      (buffer/push result s)))
  (buffer/push result ">")
  result)

# -- 2D geometry --

# Since I am sometimes using these points as keys in tables,
# these functions need to return immutable tuples, not mutable arrays.

(defn add-2d
  " vector 2D addition for points i.e. [x1 y1] and [x2 y2]"
  [[x1 y1] [x2 y2]]
  [ (+ x1 x2) (+ y1 y2) ])

(defn subtract-2d
  " vector 2D subtraction for points i.e. [x1 y1] - [x2 y2]"
  [[x1 y1] [x2 y2]]  
  [ (- x1 x2) (- y1 y2) ])

(defn scale-2d
  " scalar 2D multiplication i.e. (factor * [x y]) "
  [factor [x y]]
  [ (* factor x) (* factor y) ])

# -- sets ---------

(defn make-set "create a set" [values] (map-table (fn [x] [x true]) values))

(defn to-struct [s] (if (table? s) (table/to-struct s) s))

(defn sets=? "are two sets the same?" [s1 s2] (= ;(map to-struct [s1 s2])))
(assert (sets=? (make-set [:a :b]) (make-set [:b :a :a])) "test sets=?")
(assert (not (sets=? (make-set [:a :b :c]) (make-set [:b :a :a]))) "test not sets=?")

(defn member? "is s in set?" [s item] (truthy? (in s item)))
(assert (member? (make-set [:b :a]) :a) "member? test")

(defn union "union of two sets" [s1 s2] (merge s1 s2))

(defn difference "difference of two sets" [s1 s2]
  (make-set (filter (fn [k] (not (member? s2 k))) (keys s1))))
(assert (let [s1234 (make-set [1 2 3 4])
	      s12   (make-set [1 2])
	      s34   (make-set [3 4])]
	  (sets=? (difference s1234 s12) s34)) "difference test")

(defn set->stringy " turn table into '<set value value ...>' " [s]
  (def result @"<set ")
  (loop [[key value] :pairs s]
    (buffer/push result (string/format "%q " key)))
  (buffer/push result ">")
  result)

(defn subset? "is s1 a subset of s2?" [s1 s2]
  (def u (union s1 s2))
  (def result (sets=? u s2))
  #(printf " IN SUBSET? s1=%j s2=%j u=%j result=%j " s1 s2 u result)
  result)
(assert (subset? (make-set [1 2 3]) (make-set [1 2 3 4])) "subset? test")
(assert (not (subset? (make-set [1 7 3]) (make-set [1 2 3 4]))) "not subset? test")

(defn letters->set "return immutable struct set " [s]
  (table/to-struct (make-set (string/bytes s))))
(assert (= (letters->set "abc") {97 true 98 true 99 true}) "test letters->set")

(defn set->letters "inverse of letters->set" [ss]
  (string/from-bytes ;(sort (keys ss))))
(assert (= (set->letters (letters->set "abc")) "abc") "test set->letters")

# -- counting ----

# from https://github.com/MikeBeller/janet-cookbook#generators
(defn swap [a i j]
  (def t (a i))
  (put a i (a j))
  (put a j t))
(defn permutations [items]
  (fiber/new (fn []
               (defn perm [a k]
                 (if (= k 1)
                   (yield (tuple/slice a))
                   (do (perm a (- k 1))
                     (for i 0 (- k 1)
                       (if (even? k)
                         (swap a i (- k 1))
                         (swap a 0 (- k 1)))
                       (perm a (- k 1))))))
               (perm (array/slice items) (length items)))))
(defn print-permutations [n]
  (loop [p :in (permutations (range n))]
    (pp p)))

(defn median [values]
  (get (sort (array ;values))
       (/ (dec (length values)) 2)))
(assert (= (median [3 2 1 4 7]) 3) "check median")
    

