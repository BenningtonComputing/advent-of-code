`` utils.janet

utility functions for advent of code 2021

Notes:

 * spork   : a utility library that includes regex/match ; (use spork)
 * set     : I have some of my own set datastructure functions here, 
             but there is also a set package that I could install and use instead;
             see https://github.com/MikeBeller/janet-set
 * stringx : https://github.com/yumaikas/janet-stringx/blob/main/stringx.janet
             includes (nth string n) returns n'th char as length-1 string

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

(defn text->grid-spacey
  " convert lines of text with spaces between numbers 
    to a grid (an array of arrays) of numbers "
  [text]
  (def lines (text->lines text))
  (map line->numbers lines))

(def test-text-grid ``
   1  2   3
  12 13 101
``)
(def test-grid (text->grid-spacey test-text-grid))
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

(defn inner-grid->string-spacey [grid]
  "convert grid of numbers to printable string, leaving out border, spaces between"
  (def result @"")
  (loop [line :in (slice grid 1 -2)]
    (loop [digit :in (slice line 1 -2)]
      (buffer/push result (string/format " %i" digit)))
    (buffer/push result "\n"))
  result)

# -- 2D geometry --

# Since I am using these points as keys in tables in 05.janet,
# these functions need to return immutable tuples, not mutable arrays.

(defn point/add
  " vector 2D addition for points i.e. [x1 y1] and [x2 y2]"
  [[x1 y1] [x2 y2]]
  [ (+ x1 x2) (+ y1 y2) ])

(defn point/subtract
  " vector 2D subtraction for points i.e. [x1 y1] - [x2 y2]"
  [[x1 y1] [x2 y2]]  
  [ (- x1 x2) (- y1 y2) ])

(defn point/scale
  " scalar 2D multiplication i.e. (factor * [x y]) "
  [factor [x y]]
  [ (* factor x) (* factor y) ])

# --- data structures ---

(defn map-table
  " Given a function (func item)  that produces [key value], collect into table"
  [func items]
  (def result @{})
  (loop [i :in items] (let [[key val] (func i)] (put result key val)))
  result)

(assert (deep= @{1 [1 1] 2 [2 2]}
	       (map-table (fn [k] [k [k k]]) [1 2])) "check map-table")

(defn indices "indices of an array" [values] (tuple ;(range (length values))))
(assert (= [0 1 2] (indices [4 5 6])))

(defn last-index "last valid array index" [values] (dec (length values)))
(assert (= 2 (last-index [4 5 6])))

(defn index-pairs "all [i j] such that i<j, i<n, j<n" [n]
  (sorted (seq [i :in (range n)
		j :in (range n)
		:when (< i j)]
	       [i j])))
(assert (deep= (index-pairs 4)
	       @[[0 1] [0 2] [0 3] [1 2] [1 3] [2 3]]) "index-pairs")
  
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

(defn dict/find-min
  "return [key value] with min value in dictionary"
  [dict]
  (var lowest-key nil)
  (var lowest-value math/inf)
  (loop [[key value] :pairs dict]
    (if (< value lowest-value) (do (set lowest-key key)
				   (set lowest-value value))))
  [lowest-key lowest-value])
(assert (= [:one 1] (dict/find-min {:two 2 :three 3 :one 1})) "check find-min")

# -- vectors & matrices --

# An "ndarray" is an n-dimensional array or struct,
# with the same same size interior parts,
# for example [[[1 2] [3 4] [4 6]]] with shape [1 3 2].
# Vectors are 1D ndarrays (mutable or not),
# matrices are 2D ndarrays (mutable or not), and so on.
#
#   [ [1 2 3]
#     [4 5 6] ]    has shape  [2 3]

(defn shape "return [n-rows n-cols ...]" [ndarray &opt _shape]
  (default _shape [])
  (case (type ndarray)
    :nil _shape
    :boolean _shape
    :number _shape
    :string _shape
    :buffer _shape
    :keyword _shape
    :symbol _shape
    :array (shape (ndarray 0) [;_shape (length ndarray)])
    :tuple (shape (ndarray 0) [;_shape (length ndarray)])
    nil))
(assert (= [2]     (shape [0 0])) "shape 1D")
(assert (= [3 2]   (shape [[0 0] [1 1] [2 2]])) "shape 2D")
(assert (= [1 3 2] (shape [[[0 0] [1 1] [2 2]]])) "shape 3D")

(defn dimension [ndarray] (length (shape ndarray)))
(defn scalar? [ndarray] (= 0 (dimension ndarray)))
(defn vector? [ndarray] (= 1 (dimension ndarray)))
(defn matrix? [ndarray] (= 2 (dimension ndarray)))

(assert (scalar? 13) "scalar")
(assert (vector? [1 2 3]) "vector")
(assert (matrix? [[1 0] [0 1]]) "matrix")

(defn ndarray/type "one of [:scalar :vector :matrix nil]" [ndarray]
  (case (dimension ndarray)
    0 :scalar
    1 :vector
    2 :matrix
    nil))

# ndarray get and put (Note: can only put into mutable sub-arrays.)
(defn .get [ndarray indices] (get-in ndarray indices))
(defn .put [ndarray indices value] (put-in ndarray indices value))

(assert (= (.get test-grid [1 0]) 12)) # [[1 2 3] [12 13 101]]
(.put test-grid [0 0] 100)
(assert (= (.get test-grid [0 0]) 100))

(assert (= 6 (.get [[[1 2] [3 4] [4 6]]] [0 2 1])) ".get 3D")
(assert (deep= [[@[1 2] @[3 4] @[4 :*]]]
	       (.put [[@[1 2] @[3 4] @[4 6]]] [0 2 1] :*)) ".put 3D")

# inputs are 1D vectors (arrays or structs), output is array
(defn .add1D [& item-lists] (map + ;item-lists))
(defn .subtract1D [& item-lists] (map - ;item-lists))
(defn .multiply1D [& item-lists] (map * ;item-lists))
(defn .divide1D [& item-lists] (map / ;item-lists))

(assert (deep= (.add1D [1 2 3] [4 5 6] [7 8 9]) @[12 15 18]))
(assert (deep= (.subtract1D [1 2 3] [4 5 6] [7 8 9]) @[-10 -11 -12]))
(assert (deep= (.multiply1D [1 2 3] [4 5 6] [7 8 9]) @[28 80 162]))
(assert (deep= (.divide1D [12 100 64] [4 10 8] [3 2 2]) @[1 5 4]))

# dot product for 1D vectors
(defn dot1D [vector1 vector2] (+ ;(.multiply1D vector1 vector2)))
(assert (= 32 (dot1D [1 2 3] [4 5 6])) "vector dot product")

(defn pythdiffsq
  "square of pythagorean distance between two vectors"
  [vector1 vector2]
  (let [diff (.subtract1D vector1 vector2)]
    (dot1D diff diff)))

(defn manhattan
  "manhattan distance between two vectors"
  [vector1 vector2]
  (+ ;(map math/abs (.subtract1D vector1 vector2))))
(assert (= 30 (manhattan [1 2 3] [10 20 0])))

# matrices
(defn get-row [matrix row] (get matrix row))
(defn get-col [matrix col] (map (fn [row-items] (get row-items col)) matrix))

(assert (= [1 2] (get-row [[1 2] [3 4]] 0)) "get-row")
(assert (deep= @[1 3] (get-col [[1 2] [3 4]] 0)) "get-col")

(defn vector-dot-matrix [vector matrix]
  (seq [i :range [0 (length matrix)]]
       (dot1D vector (get-col matrix i))))

(defn matrix-dot-vector [matrix vector]
  (seq [i :range [0 (length (matrix 0))]]
       (dot1D (get-row matrix i) vector)))

(defn matrix-multiply [matrix1 matrix2]
  (def [shape1 shape2] [(shape matrix1) (shape matrix2)])
  (seq [row :range [0 (shape1 0)]]
       (seq [col :range [0 (shape2 1)]]
	    (dot1D (get-row matrix1 row) (get-col matrix2 col)))))

(defn matrix-immutable [matrix]
  (def _shape (shape matrix))
  (tuple ;(seq [row :range [0 (_shape 0)]]
               (tuple ;(seq [col :range [0 (_shape 1)]]
                            (.get matrix [row col]))))))
(assert (= [[1 2] [3 4]]
           (matrix-immutable @[@[1 2] @[3 4]])) "matrix-immutable")

(defn dot "dot product for matrices and/or vectors" [a b]
  (case [(ndarray/type a) (ndarray/type b)]
    [:vector :vector] (dot1D a b)
    [:vector :matrix] (vector-dot-matrix a b)
    [:matrix :vector] (matrix-dot-vector a b)
    [:matrix :matrix] (matrix-multiply a b)))

(assert (deep= @[17 39] (dot [[1 2] [3 4]] [5 6])) "dot matrix vector")
(assert (deep= @[23 34] (dot [5 6] [[1 2] [3 4]])) "dot vector matrix")
(assert (= 11 (dot [1 2] [3 4])) "dot vector vector")
(assert (deep= @[@[58 64] @[139 154]]
	   (dot [[1 2 3] [4 5 6]] [[7 8] [9 10] [11 12]])) "dot matrix matrix")
# notes:
#   (interleave [a b c] [d e f]) => [a d b e c f]
#   (map + [1 2 3] [4 5 6]) => [(+ 1 2) (+ 2 5) (+ 3 6)]
#   (reduce2 f [a b c]) =>  (f (f a b) c)
	
# TODO : outer product
# TODO : general ndim dot prodct

# -- rotations --

# cube symmetries i.e. octahedral group
# https://en.wikipedia.org/wiki/Octahedral_symmetry#Rotation_matrices
# 24 3x3 matrices, all 3x3 permutation matrices with determinant 1,
# so each row is one of [±1 0 0] [0 ±1 0] [0 0 ±1] with no two rows
# the same and an even number of -1's.

# -- grids & points --

# TODO - some of these assume a border; clean up names and make explicit.
#        ... and then propogate any changes into other ./*.janet files. (Ugh.)

(def directions [[1 0] [0 1] [-1 0] [0 -1]])  # right down left up on grid
(defn neighbors "4 neighbor points" [p] (map |(point/add $ p) directions))

(def directions8 [[-1 -1] [-1 0] [-1 1]
		  [ 0 -1]        [ 0 1]
                  [ 1 -1] [ 1 0] [ 1 1]])
		  
(defn neighbors8 "8 neighbor points" [p] (map |(point/add $ p) directions8))

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

(defn remove-border [grid]
  (defn remove-ends [items] (array/slice items 1 -2)) # [1 2 3 4] => [2 3]
  (map remove-ends (remove-ends grid)))
(assert (deep= @[@[1 2] @[3 4]]
               (remove-border [[0 0 0 0] [0 1 2 0] [0 3 4 0] [0 0 0 0]])))

(defn add-n-borders 
  "add n border layers"
  [grid edge n]
  (def one-border (add-border grid edge))
  (if (one? n)
    one-border
    (add-n-borders one-border edge (dec n))))
(assert (deep= @[@[0 0 0 0 0 0]
                 @[0 0 0 0 0 0]
                 @[0 0 1 2 0 0]
                 @[0 0 3 4 0 0]
                 @[0 0 0 0 0 0]
                 @[0 0 0 0 0 0]]
               (add-n-borders [[1 2] [3 4]] 0 2)))

(defn remove-n-borders
  "remove n border layers"
  [grid n]
  (def remove-one (remove-border grid))
  (if (one? n)
    remove-one
    (remove-n-borders remove-one (dec n))))
(assert (deep= @[@[1 2] @[3 4]]
               (remove-n-borders
                (add-n-borders [[1 2] [3 4]] 0 2) 2)))

(defn minus2 [x] (- x 2))

# extremes of grid for looping ; assumes it has a border
(defn .left [grid] 1)                        # index of left range-to in border
(defn .right [grid] (minus2 (length (grid 0)))) # index of right ranget- ditto
(defn .top [grid] 1)
(defn .bottom [grid] (minus2 (length grid)))

(def test-grid-border (add-border test-grid 0))
(defn in-grid?
  "is point in grid? (assumes border; border not in grid)"
  [grid [row col]]
  (and (<= (.left grid) col) (<= col (.right grid))
       (<= (.top grid) row) (<= row (.bottom grid))))
(assert (in-grid? test-grid-border [1 1]) "check 1 in-grid?")
(assert (in-grid? test-grid-border [2 3]) "check 2 in-grid?")
(assert (not (in-grid? test-grid-border [1 0])) "check 3 in-grid?")
(assert (not (in-grid? test-grid-border [0 1])) "check 4 in-grid?")
(assert (not (in-grid? test-grid-border [3 3])) "check 5 in-grid?")

(defn neighbors4-in-grid
  "up to four adjacent neighboring points if in grid, assumes border"
  [grid point]
  (filter (fn [pt] (in-grid? grid pt)) (neighbors point)))
(assert (deep= (neighbors4-in-grid test-grid-border [1 1]) @[[2 1] [1 2]]))

(defn grid-map
  "apply (func grid [row col]) to points inside border; return result array"
  # assumes grid has a border; does not apply func to border values.
  [func grid]
  (def result @[])
  (loop [row :range-to [(.top grid) (.bottom grid)]]
    (loop [col :range-to [(.left grid) (.right grid)]]
      (array/push result (func grid [row col]))))
  result)

(defn grid-loop
  "apply (func grid [row col]) to each point inside border."
  [func grid]
  (loop [row :range-to [(.top grid) (.bottom grid)]]
    (loop [col :range-to [(.left grid) (.right grid)]]
      (func grid [row col]))))

(defn grid-size "width*height size not including border" [grid]
  (* (- (length grid) 2) (- (length (grid 0)) 2)))

(defn print-grid-all [grid] (prin (grid->string grid)))    # do print border
(defn print-grid [grid] (print (inner-grid->string grid))) # don't print border
(defn print-grid-spacey [grid] (print (inner-grid->string-spacey grid)))

(defn grid-fill [shape value]
  "create a new grid with given shape, filled with given value"
  (def [height width] shape)
  (map (fn [i] (array/new-filled width value)) (range height)))

(defn grid-clone-fill [grid value]
  "create a new grid, same shape as given one, filled with given value"
  (grid-fill (shape grid) value))

(defn grid-clone [grid]
  (seq [row :in grid] (array ;row)))

# -- misc --

(defn string/nth "nth letter in string as a string"
  # could also express as (string/from-bytes (letters n)))
  [n letters] (slice letters n (inc n)))
(assert (= (string/nth 1 "abc") "b"))

(defn nth [n items]
  (case (type items)
    :tuple (items n)
    :array (items n)
    :string (string/nth n items)
    :buffer (string/nth n items)
    nil))

# (first items) is already defined, so why not second & third?
(defmacro second [items] ~(get ,items 1))
(defmacro third [items] ~(get ,items 2))
(assert (= :2 (second [:1 :2 :3])) "check second")
(assert (= :3 (third [:1 :2 :3])) "check third")

(defn array/pop0 "pop from left of array" [items value]
  # Note that this is much slower than array/pop which pops the right end.
  (def result (first items))
  (array/remove items 0)
  result)

(defn array/push0 "push onto left of array" [items & values]
  # This is much slower than array/push which pushes onto the right end.
  (array/insert items 0 ;values))

(defn distinct-freeze "freeze each to force immutable; keep uniques" [items]
  (distinct (map freeze items)))

(defmacro slice-n "extract n items from xs" [xs start n]
  ~(slice ,xs ,start (+ ,start ,n)))
(assert (= "456" (slice-n "012345678" 4 3)) "check slice-n")

(defn any
  " return true if any of (predicate value) is true, else return false "
  # Similar calling style to (all pred xs).
  # Also see builtin (any? values) which is similar but without predicate.
  [predicate values]
  (truthy? (some predicate values)))
(assert (= true (any (fn [x] (> x 3)) [1 2 4])) "check any")

# I also find myself wanting to call (all .... ) and (some ...)
# without the predicate, so :
(defn all? [args] (all identity args))
(defn some? [args] (some identity args))

(defn in? "true if x is in a collection" [collection x]
  (case (type collection)
    :array (not (nil? (index-of x collection)))
    :tuple (not (nil? (index-of x collection)))
    :string (string/find x collection)
    :struct (in collection x)
    :table (in collection x)
    false))
(assert (and                        # in? tests: 
	  (in? [0 1 2] 1)           #   element in tuple ; O(n)
	  (in? @[0 1 2] 1)          #   elmemnt in array ; O(n)
	  (in? "..ab.." "ab")       #   substring in string
	  (in? {1 :one 2 :two} 1)   #   key in struct
	  (in? @{1 :one 2 :two} 1)  #   key in table
	  "check in?"))

(defn sign
  "1, 0, -1 for positive, zero, negative"
  # Also see (cmp x y) which is similar.
  [x]
  (cond (< x 0) -1
	(> x 0)  1
	         0))

(defn positive? [x] (> 0 x))
(defn not-empty? [xs] (not (empty? xs)))

(defn double [x] (* 2 x))

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

(defn string/replace-all-many
  "replace many substrings, all of  replacments [from1 to1 from2 to2 ...]"
  [str replacements]
  (def repls @[;replacements])
  (var result str)
  (while (> (length repls) 1)
    (def [from to] [(first repls) (second repls)])
    (array/remove repls 0 2)
    (set result (string/replace-all from to result)))
  result)
(assert (= "aabbccc"
	   (string/replace-all-many "a1b2c33" ["1" "a" "2" "b" "3" "c"])))


# -- graphs ---------

(defn graph-add-edge "add edge [node1 node2] to graph" [graph [node1 node2]]
  (if-not (in? graph node1)
    (put graph node1 @[]))
  (if-not (in? (graph node1) node2)
    (array/push (graph node1) node2)))

(defn edges->graph "make graph {node:[neighbors]} " [edges]
  (def graph @{})
  (loop [[node1 node2] :in edges]
    (graph-add-edge graph [node1 node2])
    (graph-add-edge graph [node2 node1]))
  graph)

# -- sets ---------

(defn make-set "create a set" [values] (map-table (fn [x] [x true]) values))
(defn set/add "add item to set" [s item] (put s item true))
(defn set/remove "remove item from set" [s item] (put s item nil))
(defn set->array [s] (keys s))
(defn set/members [s] (keys s))
(defn set/clone [s] (make-set (keys s)))

(defn unique [items] (set->array (make-set items)))

(defn to-struct [s] (if (table? s) (table/to-struct s) s))

(defn sets=? "are two sets the same?" [s1 s2] (= ;(map to-struct [s1 s2])))
(assert (sets=? (make-set [:a :b]) (make-set [:b :a :a])) "test sets=?")
(assert (not (sets=? (make-set [:a :b :c]) (make-set [:b :a :a]))) "test not sets=?")

(defn member? "is s in set?" [s item] (truthy? (in s item)))
(assert (member? (make-set [:b :a]) :a) "member? test")

(defn union "union of two sets" [s1 s2] (merge s1 s2))

(defn intersection "intersection of two sets" [s1 s2]
  (make-set (filter (fn [k] (member? s2 k)) (keys s1))))
(assert (let [s123 (make-set [1 2 3])
	      s23  (make-set [2 3])
	      s234 (make-set [2 3 4])]
	  (sets=? (intersection s123 s234) s23)) "intersection test")

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

# straight from https://github.com/MikeBeller/janet-cookbook#generators
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
    

