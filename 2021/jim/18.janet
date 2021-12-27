``--- 18.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/18

-------------------------------------------------------``
(use ./utils)

# I'm going to treat this as a string manipulation
# exercise rather than parse the nested brackets
# into a tree.

(def comma (chr ",")) # ascii 44
(def zero (chr "0"))  #       48
(def nine (chr "9"))  #       57
                      # ... exploded integers (assuming not too big)
#(def open (chr "["))  #       91
#(def close (chr "]")) #       93
(def open (chr "{"))  #       123
(def close (chr "}")) #       125
#
# I've replaced [] with {} just to give me a bit more room
# before ascii addition from "9" overflows into the brackets.
# The curly brackets 
#   chr "{" 123
#   chr "}" 125
# would give me a bit more room; (string/replace-all "[" "{" snail)

(defn brace->curly [snail]
  (string-replace-many snail ["[" "{" "]" "}"]))

(defn explode-at
  "return index where snail should explode, or false if it shouldn't"
  [snail]
  (var i 0)
  (var depth 0)
  (def i-end (length snail))
  (while (< i i-end)
    (case (snail i)
      open (++ depth)
      close (-- depth))
    (if (= depth 5) (break))
    (++ i))
  (if (= i i-end)
    nil
    i))

(defn split-at [snail]
  "return index where snail should split, or false if it shouldn't"
  # I'm keeping each number in one byte; so "9" is ("0"+9)
  # and "9"+2 is ("0"+9+2). I'm assuming that explosions don't overflow
  # and turn an ascii number into "[" which would be "0"+33 .
  (var i 0)
  (def i-end (length snail))
  (while (< i i-end)
    (def letter (snail i))
    (if (and (> letter nine) (< letter open)) (break))
    (++ i))
  (if (= i i-end)
    nil
    i))

(defn value "numeric value of regular number" [byte] (- byte zero))

(defn add-to-number-at [snail index number]
  (string/join
   [(string/slice snail 0 index)
    (string/from-bytes (+ number (snail index)))
    (string/slice snail (inc index) -1)]))

(defn replace-left-number [snail number]
  (var result snail)
  (var i (dec (length snail)))
  (def i-end -1)
  (while (> i i-end)
    (def letter (snail i))
    (if (and (> letter comma) (< letter open)) (break))
    (-- i))
  (if (> i i-end) (set result (add-to-number-at snail i number)))
  result)

(defn replace-right-number [snail number]
  (var result snail)
  (var i 0)
  (def i-end (length snail))
  (while (< i i-end)
    (def letter (snail i))    
    (if (and (> letter comma) (< letter open)) (break))
    (++ i))
  (if (< i i-end) (set result (add-to-number-at snail i number)))
  result)

(defn explode [snail index]
  #(printf "exploding %j at %j" snail index)
  (def left-string (string/slice snail 0 index))
  #(printf "  left-string %j" left-string)
  (def left-number (value (snail (inc index))))
  #(printf "  left-number %j" left-number)  
  (def right-string (string/slice snail (+ 5 index) -1))
  #(printf "  right-string %j" right-string)
  (def right-number (value (snail (+ 3 index))))
  #(printf "  right-number %j" right-number)
  (string/format "%s0%s"
		 (replace-left-number left-string left-number)
		 (replace-right-number right-string right-number)))

(defn round-down [x] (math/floor x))
(defn round-up [x] (math/floor (+ x 0.5)))
(defn halves [x]
  (def half (/ x 2))
  [(round-down half) (round-up half)])

(defn split [snail index]
  (def [left-number right-number] (halves (value (snail index))))
  #(printf "    split numbers %j %j " left-number right-number)
  (string/format "%s%c%c%c%c%c%s"
		 (string/slice snail 0 index)
		 open
		 (+ zero left-number)
		 comma
		 (+ zero right-number)
		 close
		 (string/slice snail (inc index) -1)))

(defn snail/reduce [snail]
  (var result snail)
  (var looping true)
  (while looping
    (set looping false)
    (while (def index (explode-at result))
      (do
	(set result (explode result index))
	#(printf "   exploded at %j to %j" index result)
	))
    (if (def index (split-at result))
      (do
	(set result (split result index))
	#(printf "   split at %j to %j" index result)	
	(set looping true))))
  result)

(def explode-examples
  (map brace->curly
       ["[[[[[9,8],1],2],3],4]"
	"[7,[6,[5,[4,[3,2]]]]]"
	"[[6,[5,[4,[3,2]]]],1]"
	"[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]"
	"[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]" ]))

(printf "-- explode examples --")
(each example explode-examples
  (printf " %j => %j " example (snail/reduce example)))

(printf "-- reduce examples --")
(def reduce-example (brace->curly "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"))
(printf " %j => %j " reduce-example (snail/reduce reduce-example))

(defn snail/add [snail1 snail2]
  (def snail-sum (string/format "%c%s%c%s%c" open snail1 comma snail2 close))
  (snail/reduce snail-sum))

(defn snail/add-lines [lines] (reduce2 snail/add lines))

(def list-examples
  [``
   [1,1]
   [2,2]
   [3,3]
   [4,4]``
   ``
   [1,1]
   [2,2]
   [3,3]
   [4,4]
   [5,5]``
   ``
   [1,1]
   [2,2]
   [3,3]
   [4,4]
   [5,5]
   [6,6]``
   ``
   [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
   [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
   [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
   [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
   [7,[5,[[3,8],[1,4]]]]
   [[2,[2,2]],[8,[8,1]]]
   [2,9]
   [1,[[[9,3],9],[[9,0],[0,7]]]]
   [[[5,[7,4]],7],1]
   [[[[4,2],2],6],[8,7]]``])

(defn snail/text->lines [text]
  (text->lines (string/trim (brace->curly text))))

(printf "-- example lists --")
(each example list-examples
  (print)
  (printf example)
  (printf (snail/add-lines (snail/text->lines example))))
(print)

(defn tripdub [a b] (+ (* 3 a) (* 2 b)))

(defn snail/magnitude [snail]
  (def as-janet
    (string-replace-many snail [(string/from-bytes open)  "(tripdub "
				(string/from-bytes close) ")"
				(string/from-bytes comma) " "]))
  (eval-string as-janet))

(def magnitude-examples
  (map brace->curly
  ["[[1,2],[[3,4],5]]"
   "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
   "[[[[1,1],[2,2]],[3,3]],[4,4]]"
   "[[[[3,0],[5,3]],[4,4]],[5,5]]"
   "[[[[5,0],[7,4]],[5,5]],[6,6]]"
   "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]"]))

(printf "-- magnitude examples --")
(each example magnitude-examples
  (printf " %j => %j " example (snail/magnitude example)))
(print)

(defn text->final-magnitude [text]
  (snail/magnitude (snail/add-lines (snail/text->lines text))))

(def homework
  ``
  [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
  [[[5,[2,8]],4],[5,[[9,9],0]]]
  [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
  [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
  [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
  [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
  [[[[5,4],[7,7]],8],[[8,3],8]]
  [[9,3],[[9,9],[6,[4,9]]]]
  [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
  [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]``)

(printf "homework final sum magnitude is %j" (text->final-magnitude homework))
(print)

(def day18-text (slurp-input 18))
(printf "Day 18 Part 1 is %j\n" (text->final-magnitude day18-text))
					
(defn largest-two [text]
  (max ;(map (fn [p] (snail/magnitude (snail/add ;p)))
	     (array->pairs (snail/text->lines text)))))

(printf "largest two of the homework sums to %j\n" (largest-two homework))

(printf "Day 18 Part 2 is %j\n" (largest-two day18-text))

  
