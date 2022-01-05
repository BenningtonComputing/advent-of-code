``--- 20.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/20

      $ time janet 20.janet 

      Length of enhancement template is 512.
      Original image has 100 rows, 100 columns
      Day 20 Part 1 is 5432
      Day 20 Part 2 is 16016

      real  0m12.581s
      user  0m12.400s
      sys   0m0.176s

-------------------------------------------------------``
(use ./utils)

# Janet API notes:
#   (scan-number "1101" 2)    => 13       # convert string "1101" as base 2
#   (scan-number "A" 16)      => 10       # convert hex "A" to number base 16
#   (string/join ["aa" "bb"]) => "aabb"   # concatenate strings

(def day20-text (string/replace-all-many
                 (slurp-input 20) ["." "0" "#" "1"]))
#(print day20-text)

(def index-first-newline (string/find "\n" day20-text))
(def enhancement
  (line->digits (string/slice day20-text 0 index-first-newline)))
#(printf "%j" enhancement)
#(1 1 0 1 1 0 1 0 0 ...  1 1 1 1 0 1 0 1 0 0 1 0 1 1 0 1 0 1 0 0 1 0 0 1 0 1 0)
(printf "Length of enhancement template is %j." (length enhancement))

# Hmmm. Since element 0 is 1, on the first pass all of the infinite
# extent of 000000000 will become 1's. On the second pass, the last 0
# means that all the 111111111 will turn back into 0's. This means
# that the borders of this thing will need some thinking. Perhaps
# simplest will be to simply extend the borders outward for some
# distance (at least n for n enhancment steps) then after the
# enhancments chop the incorrect edge effects out. Or we need a
# "default" value past the edges which depends on what the edges are.

(def original-image
  (text->grid (string/trim (string/slice day20-text index-first-newline -1))))
#(print-grid-all original-image) # print including border
# 0100111000...0000111
# ...
# 100100101...1101101
(printf "Original image has %j rows, %j columns"
        (length original-image) (length (original-image 1)))

(defn double-zero-border [grid] (add-n-borders grid 0 2))

(defn edge?
  "is [row col] on edge of grid?"
  [grid row col]
  (def [rows cols] (shape grid))
  (or (= row 0) (= row (dec rows))
      (= col 0) (= col (dec cols))))

(defn nine-pixels
  "string of 9 pixels around [row col] e.g. '111101000'"
  # If we're at an edge, assume that there's enough of a border
  # that all 9 values are the same as that pixel.
  [grid row col]
  (def [from-col to-col] [(- col 1) (+ col 2)])
  (if (edge? grid row col)
    (if (zero? (.get grid [row col]))
      "000000000"
      "111111111")
    (string/format (string/repeat "%j" 9)
                   ;(array/slice (grid (- row 1)) from-col to-col)
                   ;(array/slice (grid row)       from-col to-col)
                   ;(array/slice (grid (+ row 1)) from-col to-col))))
(def tiny-test (double-zero-border [[5 6] [7 8]]))
#(print-grid-all tiny-test)
#000000
#000000
#005600
#007800
#000000
#000000
#(pp (nine-pixels tiny-test 2 3))  row=2, col=3 is the 6
#"000560780"  # i.e. 000,560,780 with 6 at center
#(pp (nine-pixels tiny-test 0 0)) # edge
#"000000000"

(defn translate
  "convert 9 digit string of 0's and 1's to 0 or 1."
  [binstring]
  (enhancement (scan-number binstring 2)))

(defn enhance-1
  "one step of the image enhancement; assumes edges are all 0's or all 1's"
  [grid]
  (def [rows cols] (shape grid))
  (def result (grid-clone grid))
  (loop [row :range [0 rows]
         col :range [0 cols]]
    (.put result [row col] (translate (nine-pixels grid row col))))
  result)

(defn enhance-n
  "n steps of image enhancement"
  [grid n]
  (def enhanced-once (enhance-1 grid))
  (if (one? n)
    enhanced-once
    (enhance-n enhanced-once (dec n))))

(defn enhance
  "(1) apply border padding, (2) enhance-n, (3) remove padding"
  # Initial padding is 0's, width of (1+2*n) steps to avoid any
  # chance of artificts coming from outside grid or from inner region,
  # since on each step such effects might spread inwards or outwards.
  [grid n]
  (enhance-n (add-n-borders grid 0 (inc (double n))) n))

(defn lit-after-n
  "number of lit pixels after n enhancement steps"
  [grid n]
  (get (frequencies (flatten (enhance grid n))) 1))

(printf "Day 20 Part 1 is %j"
        (lit-after-n original-image 2))

(printf "Day 20 Part 2 is %j"
        (lit-after-n original-image 50))


        

