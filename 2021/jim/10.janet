``--- 10.janet ---------------------------------------
  https://adventofcode.com/2021/day/10

      $ time janet 10.janet 
       parse '[({(<(())[]>[[{[]{<()<>>' : incomplete; score 0
       parse '[(()[<>])]({[<{<<[]>>(' : incomplete; score 0
       parse '{([(<{}[<>[]}>{[]{[(<()>' : illegal '}'; score 1197
       parse '(((({<>}<{<{<>}{[]{[]{}' : incomplete; score 0
       parse '[[<[([]))<([[{}[[()]]]' : illegal ')'; score 3
       parse '[{[{({}]{}}([{[{{{}}([]' : illegal ']'; score 57
       parse '{<[[]]>}<{[{[{[]{()[[[]' : incomplete; score 0
       parse '[<(<(<(<{}))><([]([]()' : illegal ')'; score 3
       parse '<{([([[(<>()){}]>(<<{{' : illegal '>'; score 25137
       parse '<{([{{}}[<[[[<>{}]]]>[]]' : incomplete; score 0
      Total score for example lines is 26397
      Day 10 Part 1 is 266301
       [({(<(())[]>[[{[]{<()<>> complete by adding }}]])})] ; points 288957 
       [(()[<>])]({[<{<<[]>>( complete by adding )}>]}) ; points 5566 
       (((({<>}<{<{<>}{[]{[]{} complete by adding }}>}>)))) ; points 1480781 
       {<[[]]>}<{[{[{[]{()[[[] complete by adding ]]}}]}]}> ; points 995444 
       <{([{{}}[<[[[<>{}]]]>[]] complete by adding ])}> ; points 294 
      Middle autocomplete score is 288957
      Day 10 Part 2 is 3404870164

      real  0m0.024s
      user  0m0.016s
      sys   0m0.004s
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
# ... but that doesn't feel very 'Janet' ;)

(def delimiters (string/bytes "()[]{}<>"))

(def [left-paren right-paren
      left-bracket right-bracket
      left-curly right-curly
      left-angle right-angle] delimiters)

(def open->close
  {left-paren right-paren
   left-bracket right-bracket
   left-curly right-curly
   left-angle right-angle})

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
    (if (in? open->close byte)
	(push stack byte)
	(if-not (= byte (open->close (pop stack)))
	  (do (set result byte)
	      (break)))))
  (if (= result :?)
    (if (zero? (length stack))
      (set result :valid)
      (set result :incomplete)))
  result)

(defn result->string
  "printable string for the possible parse results"
  [result]
  (case result
    :valid "valid"
    :incomplete "incomplete"
    (string/format "illegal '%c'" result)))

(defn score [line] (points (parse line)))
(defn total-score [lines] (+ ;(map score lines)))

(defn parse-print [line]
  "parse a line and print a summary"
  (def result (parse line))
  (prinf " parse '%s' : " line)
  (prinf "%s" (result->string result))
  (printf "; score %j" (score line)))

#(parse-print "()")

(loop [line :in example-lines] (parse-print line))
(printf "Total score for example lines is %j" (total-score example-lines))

(printf "Day 10 Part 1 is %j" (total-score day10-lines))

# -----------------

(def day10-incomplete-lines
  "keep only the incomplete lines"
  (filter (fn [line] (= (parse line) :incomplete)) day10-lines))

(def example-incomplete-lines
  (filter (fn [line] (= (parse line) :incomplete)) example-lines))

(defn completion
  "return the sequence of bytes that completes an incomplete line"
  [line]
  (def stack @[])
  (loop [byte :in (string/trim line)]
    (if (in? open->close byte)
      (push stack byte)
      (pop stack)))
  (map open->close (reverse stack)))

(def complete-points
  {right-paren 1
   right-bracket 2
   right-curly 3
   right-angle 4})

(defn complete-score [line]
  (var result 0)
  (loop [points :in (map complete-points (completion line))]
    (set result (+ points (* 5 result))))
  result)

(defn middle-score [lines] (median (map complete-score lines)))

(loop [line :in example-incomplete-lines]
  (printf " %s complete by adding %s ; points %j "
	  line
	  (string/from-bytes ;(completion line))
	  (complete-score line)))
(printf "Middle autocomplete score is %j" (middle-score example-incomplete-lines))

(printf "Day 10 Part 2 is %j" (middle-score day10-incomplete-lines))
