``--- 06.janet ---------------------------------------
  https://adventofcode.com/2021/day/6

      $ time janet 06.janet
      @"<table 3:2 4:1 1:1 2:1 >"
      day 1, count 5 = @"<table 2:2 3:1 0:1 1:1 >"
      day 2, count 6 = @"<table 1:2 2:1 0:1 6:1 8:1 >"
      day 3, count 7 = @"<table 0:2 1:1 5:1 7:1 6:1 8:1 >"
      day 4, count 9 = @"<table 0:1 4:1 6:3 5:1 7:1 8:2 >"
      day 5, count 10 = @"<table 3:1 5:3 4:1 6:2 7:2 8:1 >"
      day 6, count 10 = @"<table 2:1 4:3 3:1 5:2 6:2 7:1 >"
      day 7, count 10 = @"<table 1:1 3:3 2:1 4:2 5:2 6:1 >"
      day 8, count 10 = @"<table 0:1 2:3 1:1 3:2 4:2 5:1 >"
      day 9, count 11 = @"<table 1:3 0:1 2:2 3:2 4:1 6:1 8:1 >"
      day 10, count 12 = @"<table 0:3 1:2 2:2 3:1 5:1 7:1 6:1 8:1 >"
      day 11, count 15 = @"<table 0:2 1:2 2:1 4:1 6:4 5:1 7:1 8:3 >"
      day 12, count 17 = @"<table 0:2 1:1 3:1 5:4 4:1 6:3 7:3 8:2 >"
      day 13, count 19 = @"<table 0:1 2:1 4:4 3:1 5:3 6:5 7:2 8:2 >"
      day 14, count 20 = @"<table 1:1 3:4 2:1 4:3 5:5 6:3 7:2 8:1 >"
      day 15, count 20 = @"<table 0:1 2:4 1:1 3:3 4:5 5:3 6:2 7:1 >"
      day 16, count 21 = @"<table 1:4 0:1 2:3 3:5 4:3 5:2 6:2 8:1 >"
      day 17, count 22 = @"<table 0:4 1:3 2:5 3:3 4:2 5:2 7:1 6:1 8:1 >"
      day 18, count 26 = @"<table 0:3 1:5 2:3 3:2 4:2 6:5 5:1 7:1 8:4 >"
      test fish after 80 days is 5934 .
      Day 6 Part 1 is 351092 .
      Day 6 Part 2 is 1595330616005 .

      real 0m0.029s

  This took me a lot longer than it should have - I kept running into
  silly bugs, including dropping the last digit from the file input,
  writing (if condition thing1 thing2) and expecting both things to
  happen. And I started out by overwriting the existing day 6 fish. Ugh.
  At least it ran quickly - processing the ever-increasing original 
  lists would have been too repititious.

  I wasn't sure that the Janet numbers would do the right thing on
  integers this high. The docs say "All Janet numbers are IEEE 754
  double precision floating point numbers. They can be used to
  represent both integers and real numbers to a finite precision".
  Hmm. I'm not sure quite how they manage that without running
  into roundoff errors when doing integer arithmetic.

-------------------------------------------------------``
(use ./utils spork)

(def day6-times
  (string-delim->ints "," (first (text->lines (slurp-input 6)))))
#(printf "first 20 fish times : %j" (take 20 day6-times))
# @[3 5 3 1 4 4 5 5 2 1 4 3 5 1 ...
(printf "day6 times : %j" day6-times)

# All the reallly matters here is how many we have of each
# ... so let's count them.

(def day6-freqs (frequencies day6-times))
(printf "day6 freqs : %j" (table->stringy day6-freqs))
# @{3 58 5 54 1 83 4 54 2 50}  # 58 fish with time 3, etc

# test data
(def test-text "3,4,3,1,2")
(def test-times (string-delim->ints "," test-text))
(def test-freqs (frequencies test-times))
(printf "test times : %j" test-times)
(printf "test freqs : %j" (table->stringy test-freqs))

(defn step1
  "step fishfreqs - evolve the fish frequencies by one day, part 1"
  [ff]
  (def count0 (ff 0))    # find number that are 0 (nil if none)
  (put ff 0 nil)         # ... and remove them.
  (def new-ff (table ;(flatten
		       (map (fn [[time count]] [(dec time) count])
			    (pairs ff)))))
  (if count0                                      # if new births,
    (do
      (put new-ff 6 (+ (get new-ff 6 0) count0))  #  add to existing 6's
      (put new-ff 8 count0)))                     #  and add new ones
  new-ff)

(defn population [freqs] (+ ;(values freqs))) # fish population

(defn n-steps1
  "step n days forward"
  [n ff &opt verbose]
  (defn print-if [i r]
    (if verbose (printf "day %j, count %j = %j"
		       i (population r) (table->stringy r))))
  (var result (table/clone ff))
  (print-if 0 result)
  (for i 1 (inc n)
    (set result (step1 result))
    (print-if i result))
  result)

(n-steps1 18 test-freqs :verbose)

(defn n-count [n ff] (population (n-steps1 n ff)))

(printf "test fish after 80 days is %j ." (n-count 80 test-freqs))

#(printf "Day 6 Part 1 is %j." (n-count 80 day6-freqs))
# Day 6 Part 1 is 349901 ... wrong. My file reading dropped the last character.

(printf "Day 6 Part 1 is %j ." (n-count 80 day6-freqs))

(printf "Day 6 Part 2 is %j ." (n-count 256 day6-freqs))
