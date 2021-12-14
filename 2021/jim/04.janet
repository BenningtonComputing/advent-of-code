``--- 04.janet ---------------------------------------
 https://adventofcode.com/2021/day/4

    $janet 04.janet 
    bingo numbers are @[28 82 77 88 95 ...  11 68 72 52]
    -- first board --
    @[@[31 88 71 23 61] @[4 9 14 93 51] @[52 50 6 34 55] @[70 64 78 65 95] @[12 22 41 60 57]]
    -- last board --
    @[@[42 9 63 56 93] @[79 59 38 36 7] @[6 23 48 0 55] @[82 45 13 27 83] @[1 32 8 40 46]]
    winning rows and columns [row col] cells
    @[@[(0 0) (0 1) (0 2) (0 3) (0 4)]
      @[(1 0) (1 1) (1 2) (1 3) (1 4)]
      @[(2 0) (2 1) (2 2) (2 3) (2 4)]
      @[(3 0) (3 1) (3 2) (3 3) (3 4)]
      @[(4 0) (4 1) (4 2) (4 3) (4 4)]
      @[(0 0) (1 0) (2 0) (3 0) (4 0)]
      @[(0 1) (1 1) (2 1) (3 1) (4 1)]
      @[(0 2) (1 2) (2 2) (3 2) (4 2)]
      @[(0 3) (1 3) (2 3) (3 3) (4 3)]
      @[(0 4) (1 4) (2 4) (3 4) (4 4)]]
    -- last number was 79 ; the winner is-------
	  89      47    1022      15       1
	1086    1061    1079    1077    1099
	  51      35    1028      65      16
	  84      26    1078      46      80
	  27    1018    1021      64    1095
    unmarked values are @[89 51 84 27 47 35 26 15 65 46 64 1 16 80]
    final score is 51034 ... which is correct for part 1.
    -------- resetting boards to original state -------
     winner: id=43 , number=79 , score=51034
     winner: id=3 , number=0 , score=0
     winner: id=60 , number=89 , score=66661
     winner: id=0 , number=57 , score=27360
     winner: id=37 , number=57 , score=42180
     ...
     winners are 
     @[(79 43 51034) (0 3 0) (89 60 66661) ...
       (27 82 6750) (45 56 11610) (19 21 5434)]
     Part 1 : score for 1st winner is 51034
     Part 2 : score for last winner is 5434

-------------------------------------------------------``
(use ./utils)

(def day4-raw (slurp-input 4))

#(printf "The input for day4 starts with %j." (array/slice day4 0 3))
#(printf "Number of lines is %j." (length day4))
#(printf "Length of first line is %j." (length (day4 0)))
#(printf "----------------------------")

(def numbers (string-delim->ints "," ((text->lines day4-raw) 0)))
(printf "bingo numbers are %j" numbers)

(def text-boards (slice (string/split "\n\n" day4-raw) 1))
#(print "-- raw boards --")
#(printf "%M" text-boards)

(var boards (map text->grid text-boards))
(print "-- first board --")
(printf "%M" (boards 0))
(print "-- last board --")
(printf "%M" (last boards))

(def n 5)   # boards are n x n i.e. 5 x 5

(defn mark [x] (+ x 1000))  # make a mark by adding 1000 (numbers are 0 to 99)
(defn mark? [x] (> x 999))  # check for a mark

(defn mark-board! 
  "modify board by marking number if it is on board"
  [board number]
  (for row 0 n
    (for col 0 n
      (if (= (get2 board row col) number)
	(set2 board row col (mark number))))))

#(print "mark 14 on board 0")
#(mark-board! (boards 0) 14)
#(printf "%M" (boards 0))

(def wins
  "[row col] for each complete row and column"
  (do
    (def result @[])
    (loop [row :range [0 n]]
      (array/push result (seq [col :range [0 n]] [row col])))
    (loop [col :range [0 n]]
      (array/push result (seq [row :range [0 n]] [row col])))
    result))

(defn row-col-wins?
  "true if array of row-col positions are all marked"
  [row-cols board]
  (all (fn [[row col]] (mark? (get2 board row col))) row-cols))

(print "winning rows and columns [row col] cells")
(printf "%M" wins)

(defn winning-board?
  "true if one full row or column is marked"
  [board]
  (any (fn [row-cols] (row-col-wins? row-cols board)) wins))

(defn board-wins?
  "same as winning-board but return winning board"
  [board]
  (if (winning-board? board)
    board
    false))

# --- testing - disable before playing real game -------------------------
#(print "board 0 has won? " (winning-board? (boards 0)))
#(print "last board has won? " (winning-board? (last boards)))
#(print "marking 2nd row in board 0")
#(loop [x :in [4 9 14 93 51]] (mark-board! (boards 0) x))   # 2nd row
#(print "board 0 has won now? " (winning-board? (boards 0)))
#(print "marking 2nd col in last board")
#(loop [x :in [9 59 23 45 32]] (mark-board! (last boards) x))  # 2nd col
#(print "last board has won now? " (winning-board? (last boards)))

# Functions that examine and modify the global array of boards.
(defn winner? [] (any winning-board? boards))
(defn get-winner [] (some board-wins? boards))
(defn mark-boards!
  [value]
  (loop [board :in boards] (mark-board! board value)))

(defn print-board [board]
  (for col 0 n
    (for row 0 n
      (prinf "%8d" (get2 board row col)))
    (prinf "\n")))

(defn unmarked [board]
  (filter (fn [x] (not (mark? x))) (flatten board)))

(defn final-score [number board]
  (* number (+ ;(unmarked board))))

(defn play []
  "mark each number in turn on all the boards. 
   return the first winning board"
  (var turn -1)
  (while (not (winner?))
    (++ turn)
    (mark-boards! (numbers turn)))
  [(numbers turn) (get-winner)])

(defn play-all []
  "mark each number in turn on all the boards. 
   keep playing until the end.
   return an array giving all winners, 
   [board_id number] in the correct order"
  (def winners @[])
  (def has-won @[])
  (loop [number :in numbers]
    (mark-boards! number)
    (loop [id :in (indices boards)]
      (if (and (not (in? has-won id)) (board-wins? (boards id)))
	(do
	  (array/push has-won id)
	  (def score (final-score number (boards id)))
	  (printf " winner: id=%j , number=%j , score=%j" id number score)
	  (array/push winners [number id score])))))
  winners)

#-- part1 code 
(def [last-number winner] (play))   # part 1 version
(printf "-- last number was %j ; the winner is-------" last-number)
(print-board winner)
(printf "unmarked values are %j" (unmarked winner))
(printf "final score is %j ... which is correct for part 1."
	(final-score last-number winner))

#-- for part 2, running through all the winners
#   ... and now extracting 1st and last for parts 1 & 2.

# --- reset boards to initial position
(printf "-------- resetting boards to original state -------")
(set boards (map text->grid text-boards))

(def winners (play-all))
(def [number0 winner0-id score0] (winners 0))
(def [number-last winner-last-id score-last] (last winners))

(printf "winners are ")
(pp winners)
(printf "Part 1 : score for 1st winner is %j" score0)
(printf "Part 2 : score for last winner is %j" score-last)

# ---------------------------------------------------

