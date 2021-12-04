" utils.janet "

# --- input ---

(defn slurp-input "get input for day n" [n]
  (slurp (string/join ["./inputs/" (string n) ".txt"])))

(defn text->lines
  "return array of non-empty lines from text"
  [text]
  (filter (fn [x] (> (length x) 0))
	  (string/split "\n" text)))

(defn text->numbers
  "text is one number per line ; return array of numbers"
  [text]
  (map parse (text->lines text)))

(defn collapse-space [text] (peg/replace-all ~(some " ") " " text))
(assert (deep= (collapse-space "a  b  c") @"a b c"))

(defn filter-out-nil [values] (filter (fn [x] (not (nil? x))) values))

(defn line->numbers
  "line is numbers with any number of spaces between; return array of numbers"
  [line]
  (filter-out-nil (map scan-number (string/split " " (collapse-space line)))))
(deep= (line->numbers "1  2   3") @[1 2 3])

(defn text->grid
  " convert lines of text with spaces between numbers 
    to an array of array of numbers "
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

# --- data structures ---

(defn indices "indices of an array" [values] (range (length values)))
(assert (deep= (indices [4 5 6]) @[0 1 2]))

(defn array/pairs 
  " Given an array [1 2 3], return array of all combos of two 
    distinct elements [[1 2] [1 3] [2 1] [2 3] [3 1] [3 2] "
  # This name is not the best; "pairs" means something else in janet.
  [values]
  (seq [x :in (indices values)
	y :in (indices values)
	:when (not (= x y))]
       [(values x) (values y)]))
(assert (deep= (array/pairs [1 2 3])
	       @[[1 2] [1 3] [2 1] [2 3] [3 1] [3 2]]))

(defn get2
  " return value at given row and column of 2d grid i.e. array of array "
  [grid row col]
  ((grid row) col))

(assert (= (get2 test-grid 1 0) 12)) # [[1 2 3] [12 13 101]]

(defn set2
  " set 2d grid (i.e. array of arrays) at (row,column) to given value"
  [grid row col value]
  (set ((grid row) col) value))

(set2 test-grid 0 0 100)
(assert (= (get2 test-grid 0 0) 100))

# -- misc --

(defn any
  " return true if any of (predicate value), else return false "
  [predicate values]
  (if (some predicate values)
    true
    false))

