" utils.janet "

(defn foo "a function" [x y] (+ x y))

## already part of janet (!)
#(defn slurp
#  "read an entire file"
#  [filename]
#  (with [infile (file/open filename :r)]
#	(file/read infile :all)))

(defn slurp-input "get input for day n" [n]
  (slurp (string/join ["./inputs/" (string n) ".txt"])))

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

#(var a (file->ints "ints.txt"))
#(print "(type a) is " (type a))
#(pp a)
#
#(var b @[1 2 3 4 5 6 7 8])
#(print "(type b) is " (type b))
#(pp b)
#
#(print "(= a b is) " (= a b))
#
# Hmmm. So mutable arrays do that look the same are not = to each other,
# while immutable arrays that look the same are = to each other.
#
#   (var a-mutable @[1 2 3])
#   (var b-mutable @[1 2 3])
#   (= a-mutable b-mutable)    # -> false
#
#   (var a [1 2 3])
#   (var b [1 2 3])
#   (= a b)           # -> true
#
# Looks like I can force the behavior I want by creating immutable copies
# of these arrays with [;a], where the ";" is the "splice" operation
# that essentially inserts the values there, unpacking them all.
# But it seems pretty kludgy.
#

(defn array=
  " equality for mutable arrays that is true if they look the same "
  [& arrays]
  (all identity (map = ;arrays)))
  # alternate implementation : (= ;(seq [a :in arrays] [;a])))
(assert (array= @[1 2 3] @[1 2 3]) "testing array=")
#(assert (array= (file->ints "./misc/ints.txt") @[1 2 3 4 5 6 7 8])
#	"testing file->ints")

(defn indeces "indeces of an array" [values] (range (length values)))
(assert (array= (indeces [4 5 6]) [0 1 2]))

(defn array/pairs 
  " Given an array [1 2 3], return array of two 
    distinct elements [[1 2] [1 3] [2 1] [2 3] [3 1] [3 2] "
  [values]
  (seq [x :in (indeces values)
	y :in (indeces values)
	:when (not (= x y))]
       [(values x) (values y)]))
(assert (array= (array/pairs [1 2 3])
		[[1 2] [1 3] [2 1] [2 3] [3 1] [3 2]]))

(defn lines->numbers [lines]
    (map parse                                   # string -> integer
	 (filter (fn [x] (> (length x) 0))       # ignore ""
		 (string/split "\n" lines))))

