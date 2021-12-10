``--- 10.janet ---------------------------------------
  https://adventofcode.com/2021/day/10


-------------------------------------------------------``
(use ./utils)

(def example-lines [
  "[({(<(())[]>[[{[]{<()<>>"
  "[(()[<>])]({[<{<<[]>>("
  "{([(<{}[<>[]}>{[]{[(<()>"
  "(((({<>}<{<{<>}{[]{[]{}"
  "[[<[([]))<([[{}[[()]]]"
  "[{[{({}]{}}([{[{{{}}([]"
  "{<[[]]>}<{[{[{[]{()[[[]"
  "[<(<(<(<{}))><([]([]()"
  "<{([([[(<>()){}]>(<<{{"
  "<{([{{}}[<[[[<>{}]]]>[]]" ])

(def day10-lines (text->lines (slurp-input 10)))

# OK : naming and working with these symbols.
# Janet doesn't have a character type; "(" is a length 1 string.
# And indexing into strings gives bytes i.e. integer numbers 0 to 255,
# not bytes. So for example
#   (chr "a")  =>  97    # (This function name is not what I'd expect.)
#   (type (chr "a"))  => :number              
#   (string/bytes "abc") => (97 98 99)
#   (string/from-bytes 97 98) => "ab"
#   (string/from-bytes ;(string/bytes "abcd"))  => "abcd"
#   (get "abc" 2)   # get byte with index 1   => 99
#   ("abc" 2)       # same                    => 99
#   (loop [c :in "abc"] (prinf "%j " c)       => 97 98 99
#   (loop [c :in "abc"] (prinf "%c " c))      => a b c  (%c format byte as char)
#
# I could force "abc" into ["a" "b" "c"], and work length 1 strings
# using notations that are more familiar to me, i.e. (if (= token ")")
# ... but that doesn't feel very 'Janet'.

(def delimiters (string/bytes "()[]{}<>"))

(def [left-paren right-paren
      left-bracket right-bracket
      left-curly right-curly
      left-angle right-angle] delimiters)

(def open-close
  {left-paren right-paren
   left-bracket right-bracket
   left-curly right-curly
   left-angle right-angle})

(defn in? [data-struc key] (truthy? (in data-struc key)))

(assert (in? open-close left-paren) "( in open-close")
(assert (not (in? open-close right-paren)) ") not in open-close")

(def points
  {right-paren 3
   right-bracket 57
   right-curly 1197
   right-angle 25137
   :valid 0
   :incomplete 0})

(def push array/push)
(def pop array/pop)

(defn parse
  "return the first illegal character or :valid or :incomplete"
  [line]
  (def stack @[])
  (var result :?)
  (loop [byte :in (string/trim line)]
    (if (in? open-close byte)
	(push stack byte)
      (do
	(def expect (get open-close (pop stack)))
	(if-not (= byte expect)
	  (do
	    (set result byte)
	    (break))))))
  (if (= result :?)
    (if (zero? (length stack))
      (set result :valid)
      (set result :incomplete)))
  result)

(defn result->string
  [result]
  (case result
    :valid "valid"
    :incomplete "incomplete"
    (string/format "illegal '%c'" result)))

(defn score [line] (points (parse line)))
(defn total-score [lines] (+ ;(map score lines)))

(defn parse-print [line]
  (def result (parse line))
  (prinf " parse '%s' : " line)
  (prinf "%s" (result->string result))
  (printf "; score %j" (score line)))

#(parse-print "()")

(loop [line :in example-lines] (parse-print line))
(printf "Total score for example lines is %j" (total-score example-lines))

(printf "Day 10 Part 1 is %j" (total-score day10-lines))
