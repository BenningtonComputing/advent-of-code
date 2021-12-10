``--- 08.janet ---------------------------------------
  https://adventofcode.com/2021/day/8

      $ time janet 08.janet 
      count1478 test is 26
      Day 8 Part 1 is 261
      translated example line is 5353
      translated longer test is @[8394 9781 1197 9361 4873 8418 4548 1625 8717 4315]
      Day 8 Part 2 is 987553

      real  0m0.102s
      user  0m0.079s
      sys  0m0.008s

  This one took me much longer than I would have liked.
  I waffled back and forth between several approaches,
  and re-worked several the deductive set manipulations one that
  I eventually implemented. I also wrote (and debugged) 
  some set functions and conversions between letters and sets
  along the way. Deciding on a way to notate the problem
  that made sense to me also took several attempts.

-------------------------------------------------------``
(use ./utils)

# 0     abcefg         6
# 1     cf         2 
# 2     acdeg         5        
# 3     acdfg         5 
# 4     bcdf         4
# 5     abdfg         5 
# 6     abdefg         6
# 7     acf         3
# 8     abcdefg         7
# 9     abcdfg         6
# 2 letters => digit is 1
# 3 letters => digit is 7 ... this is the "easy" part, just looking at length
# etc
(def length-encoding @{2 1 3 7 4 4 7 8})

(def example-line
  "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf")

(def test-text
 ``be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
   edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
   fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
   fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
   aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
   fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
   dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
   bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
   egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
   gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce ``)

(def day8-text (slurp-input 8))
#(print day8-text)

(defn sort-letters
  "convert string e.g. 'cba' to letter sorted string e.g. 'abc'"
  [s]
  (string/from-bytes ;(sort (array ;(string/bytes s)))))

(defn parse-line
  "parse one of line of puzzle input. 
   return {:10 ten-words-letter-sorted :4 four-words-letter-sorted} "
  [line]
  (def [left right] (map string/trim (string/split " | " line)))
  #(printf "left %j" left)
  #(printf "right %j" right))
  (def [tenwords fourwords] (map (fn [s] (string/split " " s)) [left right]))
  #(printf "tenwords %j" tenwords)
  #(printf "fourwords %j" fourwords)  
  {:10 (map sort-letters tenwords) :4 (map sort-letters fourwords)})

(defn translate-easy
  "translate the four digits using only their length i.e. easy version"
  [parsed]
  (map (fn [word] (get length-encoding (length word) :?)) (parsed :4)))

(defn translate-easy-text
  [text]
  (def parsings (map parse-line (text->lines text)))
  (def numbers (map translate-easy parsings))
  (flatten numbers))

(defn count1478 [text]
  (length (filter number? (translate-easy-text text))))

(printf "count1478 test is %j" (count1478 test-text))
(printf "Day 8 Part 1 is %j" (count1478 day8-text))

# ----------------------------------------
# The puzzle says "... through a little deduction ..."
#
# OK, thinking out loud.
#
# digit word       letter_count    (for correct words)
# ----- ------     ------------
# 0     abcefg         6
# 1     cf         2 
# 2     acdeg         5        
# 3     acdfg         5 
# 4     bcdf         4
# 5     abdfg         5 
# 6     abdefg         6
# 7     acf         3
# 8     abcdefg         7
# 9     abcdfg         6
#
# So, given ten words, what can we deduce?
#
# know        cf       1   only one with two letters      |  "the easy part"
# know        acf      7   only one with three letters    |
# know        bcdf     4   only one with four letters     |
# know        abcdefg  8   only one with seven letters    |
#
# know        acdfg    3   only five letter word containing acf
# know        abcdfg   9   only six letter word containing bcdf
#
# know        abcefg   0   only remaining six letter word having cf
# know        abdefg   6   only remaining six letter word
#
# know        e            abcdefg - abcdfg
# know        acdeg    2   only remaining five letter containing e
# know        abdfg    5   only remaining five letter word
#
# Looks like the solution determined and can be done with
# some set operations ... if I haven't made an error in doing it by hand.
#
# -----------------------------------------
#
# I think this is smaller enough to do it by a more brute-forcy
# automated approach - that would be another approach.
#
# The number of assignments abcdefg => abcdefg
# is the number of rearrangments, which is the
# number of permuations. For 7 of them, that is 7! = 5040,
# which feels manageable.
#
# We have 7 letters, so the total number of subsets is 2**7 = 128.
# We have exactly 10 valid subsets, corresponding to numerals 0 to 9.
#
# For each line, we have 10 new subsets.
# Then the question is which permutation gives us the original subsets.
#
# But ... for now I'll stick to the set deduction approach.
#
# And to avoid comparing abd with dba, I'll only work with
# these letter combination strings in sorted form, i.e. "abcd" not "bacd".
#
# I've put some set operations into ./utils.janet, and some functions
# to convert words (thought of as a bag of letters) to sets.

(def digit
  "mapping from correct words (e.g. 'cf') to correct digits (e.g. 1)"
  (zipcoll
   ["abcefg" "cf" "acdeg" "acdfg" "bcdf" "abdfg" "abdefg" "acf" "abcdefg" "abcdfg"]
   (range 10)))
(assert (= (digit "cf") 1) "check digit")

(def example-parsed (parse-line example-line))
(def example10 (example-parsed :10))
#(pp example10)
# @["abcdefg" "bcdef" "acdfg" "abcdf" "abd" "abcdef" "bcdefg" "abef" "abcdeg" "ab"]

(defn find-length "return first word in words that has length n" [words n]
  (find (fn [s] (= n (length s))) words))

(defn find-all-length "return @[word ...] with given length" [words n]
  (filter (fn [s] (= n (length s))) words))

(defn letters-in? "are letters in word1 all in word2?" [word1 word2]
  (subset? ;(map letters->set [word1 word2])))

(defn letter-difference "return those letters in word1 which are not in word2"
  [word1 word2]
  (set->letters (difference ;(map letters->set [word1 word2]))))

(defn remove-word "modify array words by removing word"
  [words word]
  (array/remove words (find-index (fn [w] (= w word)) words)))

(defn solve "return a translation table {word number} given 10 words"
  [words]
  (def result @{})
  
  # First the four easy ones.
  
  (def cf (find-length words 2))
  (put result cf (digit "cf"))
  
  (def acf (find-length words 3))
  (put result acf (digit "acf"))
  
  (def bcdf (find-length words 4))
  (put result bcdf (digit "bcdf"))

  (def abcdefg "abcdefg") # (No need to look; must be this.)
  (put result abcdefg (digit "abcdefg"))

  # Then the six harder ones.
  #
  # At this point the remaining unknown words are
  #  five letters : acdeg acdfg abdfg
  #  six letters : abcefg abdefg abcdfg

  # acdfg is the five letter word containing acf.
  (var acdfg "?")
  (def unknown-fives (find-all-length words 5)) # remaining five letter words
  (loop [word :in unknown-fives]
    (if (letters-in? acf word) (set acdfg word)))
  (put result acdfg (digit "acdfg"))
  (remove-word unknown-fives acdfg)

  # abcdfg is the six letter word containing bcdf
  (var abcdfg "?")
  (def unknown-sixes (find-all-length words 6))
  (loop [word :in unknown-sixes]
    (if (letters-in? bcdf word) (set abcdfg word)))
  (put result abcdfg (digit "abcdfg"))
  (remove-word unknown-sixes abcdfg)

  # abcefg is the remaining six letter word containing cf
  (var abcefg "?")
  (loop [word :in unknown-sixes]
    (if (letters-in? cf word) (set abcefg word)))
  (put result abcefg (digit "abcefg"))
  (remove-word unknown-sixes abcefg)

  # abdefg is the only remaining six letter word
  (put result (first unknown-sixes) (digit "abdefg"))

  # e is abcdefg - abcdfg
  (def e (letter-difference abcdefg abcdfg))

  # acdeg is the only remaining five letter word containing e
  #(printf " solving : e is %j" e)
  #(printf "           unknown-fives is %j" unknown-fives)  
  (var acdeg "?")
  (loop [word :in unknown-fives]
    (if (letters-in? e word) (set acdeg word)))
  #(printf "           found acdeg as %j" acdeg)
  (put result acdeg (digit "acdeg"))
  (remove-word unknown-fives acdeg)

  # abdfg is the only remaining five letter word
  (put result (first unknown-fives) (digit "abdfg"))  

  # And that's all of them!
  result)

(def example-answer (solve example10))
#(pp example-answer)

(defn digits->value 
  "convert [1 2 3 4] to 1234"
  [digits]
  # Yes, there are more elegant ways to do this. ;)
  (+ (* 1000 (digits 0))
     (* 100 (digits 1))
     (* 10 (digits 2))
     (digits 3)))

(defn translate-line
  "translate one line into a four digit number"
  [line]
  (def parsed (parse-line line))
  (def word->digit (solve (parsed :10)))
  (def digits (map (fn [w] (word->digit w)) (parsed :4)))
  (digits->value digits))

(printf "translated example line is %j" (translate-line example-line))

(defn translate-text
  "translate lines of text into array of four-digit numbers"
  [text]
  (map translate-line (text->lines text)))

(printf "translated longer test is %j" (translate-text test-text))

(printf "Day 8 Part 2 is %j" (+ ;(translate-text day8-text)))


