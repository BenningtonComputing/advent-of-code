" utils.janet "

(defn slurp-input "get input for day n" [n]
  (slurp (string/join ["./inputs/" (string n) ".txt"])))

(defn lines [text] (string/split "\n" text))

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

(defn text->lines
  "return array of non-empty lines from text"
  [text]
  (filter (fn [x] (> (length x) 0))
	  (string/split "\n" text)))

(defn text->numbers [text] (map parse (text->lines text)))

