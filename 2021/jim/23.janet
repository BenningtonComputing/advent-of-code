``--- 23.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/23

   $ time janet 23.janet 
   Day 23 Part 1 is 15358
    solution found 52416 ; counter=1314873
    solution found 52216 ; counter=1317076
    solution found 51836 ; counter=3998630
    solution found 51636 ; counter=4000833
    solution found 51436 ; counter=4160032
   Finished search or hit max : 5 solutions, 25222417 positions examined
   day23 min is 51436

   real  34m51.061s
   user  22m53.578s
   sys   0m38.319s

My code had many bugs - this took me a long time to implement,
even in this very slow (30min) version.

I haven't yet put in some sort of memoization of graph nodes, which I
expect would speed things up. Djikstra's min search algorithm would
probably be the right way to go, with the score as the distance from
the start.

-------------------------------------------------------``
(use ./utils spork)

# example starting config
#   
#  #############
#  #...........#
#  ###B#C#B#D###
#    #A#D#C#A#
#    #########
#
##############################

# day23 input

# visualizing a solution to part 1 by hand :

#############
#...........#
###C#A#B#D###
  #D#C#A#B#
  #########

#############
#.........D.#     2D
###C#A#B#.###
  #D#C#A#B#
  #########

#############
#.......B.D.#     2B
###C#A#.#.###
  #D#C#A#B#
  #########

#############
#AA.....B.D.#     8A + 4A = 12A
###C#.#.#.###
  #D#C#.#B#
  #########

#############
#AA.....B.D.#     6C + 6C = 12C
###.#.#C#.###
  #D#.#C#B#
  #########

#############
#AA.......D.#     5B + 7B = 12B
###.#B#C#.###
  #D#B#C#.#
  #########

#############
#AA.........#     3D + 9D = 12D
###.#B#C#D###
  #.#B#C#D#
  #########

#############
#...........#     3A + 3A = 6A
###A#B#C#D###
  #A#B#C#D#
  #########

# So total cost for that solution is
# 2D + 2B + 12A + 12C + 12B + 12D + 6A
# (12A + 6A) + (2B + 12B) + 12C + (2D+12D)
# = 18A + 14B + 12C + 14D
# = 18 + 140 + 1200 + 14000 = 15358
(printf "Day 23 Part 1 is %j" (+ 18 140 1200 14000))
# ... which is in fact the right answer for part 1.

# ==================================================

# --- board coordinates -------
#############
#..,.,.,.,..#      y=0        <= hall
###.#.#.#.###      y=1        <= room 
  #.#.#.#.#        y=2           .
  #.#.#.#.#        y=3           .
  #.#.#.#.#        y=4           .
  #########
#0123456789A       x = 0 to 10
#  A B C D         <= rooms A through D
# -----------------------------

(def hallx [0 1 3 5 7 9 10])              # room -> hall places to move
(def all-hallx [0 1 2 3 4 5 6 7 8 9 10])
(def hally 0)
(def roomxs [2 4 6 8])
(def roomys [1 2 3 4])
(def home { 2 :A 4 :B 6 :C 8 :D })
(def scores { :A 1 :B 10 :C 100 :D 1000 })
                                
(defn set-state [text]
  (def lettergrid (text->lines (string/trim
    (string/replace-all-many text ["*" "" "#" "" " " ""]))))
  (def result @{ :score 0 :moves 0 :at @{}})
  (loop [col :range [0 11]]
    (put (result :at) [col hally] (keyword (string/nth col (lettergrid 0)))))
  (loop [row :range [1 5] col :range [0 4]]
    (put (result :at) [(roomxs col) row]
         (keyword (string/nth col (lettergrid row)))))
  result)

(defn print-state [state]
  (def result @"
#############\n
#  . . . .  #\n
### # # # ###\n
  # # # # #  \n
  # # # # #  \n
  # # # # #  \n
  #########  ")
  (eachp [[x y] what] (state :at)
         (put result (+ (* 14 (+ 1 y)) (+ 1 x)) ((describe what) 1)))
  (print result))

(def example2-state (set-state ``
#############
#...........#
###B#C#B#D###
  #D#C#B#A#
  #D#B#A#C#
  #A#D#C#A#
  #########
``))
#(print-state example2-state)

(def day23-state (set-state ``
#############
#...........#
###C#A#B#D###
  #D#C#B#A#
  #D#B#A#C#
  #D#C#A#B#
  #########
``))

(def testy1-state (set-state ``
#############
#BD.........#
###.#C#B#D###
  #.#C#B#A#
  #D#B#A#C#
  #A#D#C#A#
  #########
``))

(def testy2-state (set-state ``
#############
#BD.......AD#
###.#C#B#.###
  #.#C#B#D#
  #.#B#A#C#
  #A#D#C#A#
  #########
``))

(def testy3-state (set-state ``
#############
#BD...C....D#
###.#.#B#D###
  #.#C#B#A#
  #.#B#A#C#
  #A#D#C#A#
  #########
``))

(def testy4-state (set-state ``
#############
#BD.....A.AD#
###.#C#B#.###
  #.#C#B#D#
  #.#B#A#C#
  #.#D#C#A#
  #########
``))

(def testy5-state (set-state ``
#############
#BD.C.C.A.AD#
###.#.#B#.###
  #.#.#B#D#
  #.#B#A#C#
  #.#D#C#A#
  #########
``))

(def almost-goal-state (set-state ``
#############
#...A.......#
###.#B#C#D###
  #A#B#C#D#
  #A#B#C#D#
  #A#B#C#D#
  #########
``))

(def goal-state (set-state ``
#############
#...........#
###A#B#C#D###
  #A#B#C#D#
  #A#B#C#D#
  #A#B#C#D#
  #########
``))

(def solns
  (map set-state
       (string/split "\n\n" ``
#############
#..........D#
###B#C#B#.###
  #D#C#B#A#
  #D#B#A#C#
  #A#D#C#A#
  #########

#############
#A.........D#
###B#C#B#.###
  #D#C#B#.#
  #D#B#A#C#
  #A#D#C#A#
  #########

#############
#A........BD#
###B#C#.#.###
  #D#C#B#.#
  #D#B#A#C#
  #A#D#C#A#
  #########

#############
#A......B.BD#
###B#C#.#.###
  #D#C#.#.#
  #D#B#A#C#
  #A#D#C#A#
  #########

#############
#AA.....B.BD#
###B#C#.#.###
  #D#C#.#.#
  #D#B#.#C#
  #A#D#C#A#
  #########

#############
#AA.....B.BD#
###B#.#.#.###
  #D#C#.#.#
  #D#B#C#C#
  #A#D#C#A#
  #########

#############
#AA.....B.BD#
###B#.#.#.###
  #D#.#C#.#
  #D#B#C#C#
  #A#D#C#A#
  #########

#############
#AA...B.B.BD#
###B#.#.#.###
  #D#.#C#.#
  #D#.#C#C#
  #A#D#C#A#
  #########

#############
#AA.D.B.B.BD#
###B#.#.#.###
  #D#.#C#.#
  #D#.#C#C#
  #A#.#C#A#
  #########

#############
#AA.D...B.BD#
###B#.#.#.###
  #D#.#C#.#
  #D#.#C#C#
  #A#B#C#A#
  #########

#############
#AA.D.....BD#
###B#.#.#.###
  #D#.#C#.#
  #D#B#C#C#
  #A#B#C#A#
  #########

#############
#AA.D......D#
###B#.#.#.###
  #D#B#C#.#
  #D#B#C#C#
  #A#B#C#A#
  #########

#############
#AA.D......D#
###B#.#C#.###
  #D#B#C#.#
  #D#B#C#.#
  #A#B#C#A#
  #########

#############
#AA.D.....AD#
###B#.#C#.###
  #D#B#C#.#
  #D#B#C#.#
  #A#B#C#.#
  #########

#############
#AA.......AD#
###B#.#C#.###
  #D#B#C#.#
  #D#B#C#.#
  #A#B#C#D#
  #########

#############
#AA.......AD#
###.#B#C#.###
  #D#B#C#.#
  #D#B#C#.#
  #A#B#C#D#
  #########

#############
#AA.......AD#
###.#B#C#.###
  #.#B#C#.#
  #D#B#C#D#
  #A#B#C#D#
  #########

#############
#AA.D.....AD#
###.#B#C#.###
  #.#B#C#.#
  #.#B#C#D#
  #A#B#C#D#
  #########

#############
#A..D.....AD#
###.#B#C#.###
  #.#B#C#.#
  #A#B#C#D#
  #A#B#C#D#
  #########

#############
#...D.....AD#
###.#B#C#.###
  #A#B#C#.#
  #A#B#C#D#
  #A#B#C#D#
  #########

#############
#.........AD#
###.#B#C#.###
  #A#B#C#D#
  #A#B#C#D#
  #A#B#C#D#
  #########

#############
#..........D#
###A#B#C#.###
  #A#B#C#D#
  #A#B#C#D#
  #A#B#C#D#
  #########

#############
#...........#
###A#B#C#D###
  #A#B#C#D#
  #A#B#C#D#
  #A#B#C#D#
  #########
``)))

(defn apod [state [x y]] ((state :at) [x y]))
(assert (= :B (apod example2-state [2 1])) "check apod")

(defn empty? [state [x y]] (= ((state :at) [x y]) :.))
(assert (empty? testy1-state [2 0]))
(assert (empty? testy1-state [2 2]))
(assert (not (empty? testy1-state [0 0])))
(assert (not (empty? testy1-state [4 3])))

(defn top-in-room [state roomx]
  (def index (find |(not (empty? state [roomx $])) roomys))
  (if index
    [roomx index]
    nil))
(assert (= [4 2] (top-in-room testy3-state 4)))
(assert (= [2 3] (top-in-room testy1-state 2)))
(assert (nil? (top-in-room testy4-state 2)))

(defn top-empty [state roomx]
  (def index (find |(empty? state [roomx $]) (reverse roomys)))
  (if index
    [roomx index]
    nil))
(assert (= [2 4] (top-empty testy4-state 2)))
(assert (nil? (top-empty testy4-state 4)))
(assert (= [4 2] (top-empty testy5-state 4)))

(defn room-phase1? [state roomx]
  # phase 1 : moving from room to hall (at least one non-matching present)
  # phase 2 : moving from hall (after non-matching letters removed)
  (def pod (home roomx)) 
  (any (fn [y]
         (let [value ((state :at) [roomx y])]
           (and (not= value :.) (not= value pod))))
       roomys))
(assert (room-phase1? testy2-state 4))       # 4 is 2nd room
(assert (not (room-phase1? testy2-state 2))) # 2 is 1st room
(assert (not (room-phase1? testy4-state 2)))
(assert (room-phase1? testy4-state 4))

(defn can-move? [state [x1 y1] [x2 y2]]
  (def [lowx highx] [(min x1 x2) (max x1 x2)])
  (def roomy (max y1 y2))
  (def roomx (if (= roomy y1) x1 x2))
  (and (not (empty? state [x1 y1]))
       (if (= y1 hally) (= (apod state [x1 y1]) (home x2)) true)
       (empty? state [x2 y2])
       (all |(empty? state [$ hally]) (range (inc lowx) highx))
       (all |(empty? state [roomx $]) (range 1 roomy))))
(assert (can-move? testy2-state [9 0] [2 3]))
(assert (not (can-move? testy1-state [0 0] [2 1])))
(assert (can-move? testy4-state [7 0] [2 4]) "can-move? test4 A to bottom")
(assert (can-move? almost-goal-state [3 0] [2 1]) "can-move? almost-goal")

(defn moves [state]
  # a move is [[x1 y1] [x2 y2]]
  # only two sorts of moves , in phases 1 & 2 for that room :
  #  (1) from one of its starting columns to somewhere in the top row,
  #      if the path between is empty
  #  (2) from a place in the top row to its final home column,
  #      if the path between is empty, and
  #      if there are no incorrect apods in the final home column
  (def result @[])
  # (a) : look for highest in each room ; try to move into hallway
  (loop [rx :in roomxs]
    (if (room-phase1? state rx)
      # phase1 : from this room to hall
      (let [room-top (top-in-room state rx)]
        (loop [x :in hallx]
          (let [move-to [x hally]]
            (if (can-move? state room-top move-to)
              (array/push result [room-top move-to])))))
      # phase2 : from hall to this room
      (let [empty-top (top-empty state rx)]
        #(printf "moves phase2 rx=%j empty-top=%j" rx empty-top)
        (if empty-top
          (let [move-to empty-top]
            (loop [x :in hallx]
              (let [move-from [x hally]]
                #(printf "      move-to=%j move-from=%j" move-to move-from)
                #(printf "      can-move? %j" (can-move? state move-from move-to))
                (if (can-move? state move-from move-to)
                  (array/push result [move-from move-to])))))))))
  (reverse result))
(assert (= [] (freeze (moves goal-state))) "moves goal")
(assert (= [[[3 0] [2 1]]]
           (freeze (moves almost-goal-state))) "moves almost-goal") # FAIL!

(defn score [state start end]
  (* (manhattan start end) (scores (apod state start))))

(defn make-move [state start end]
  (def result @{:score (+ (score state start end) (state :score))
                :moves (inc (state :moves))
                :at (table/clone (state :at))})
  (put (result :at) end (apod state start))
  (put (result :at) start :.)
  result)

(defn goal? [state]
  (all? (seq [x :in roomxs y :in roomys]
             (= (apod state [x y]) (home x)))))
(assert (goal? goal-state) "goal is goal")
(assert (not (goal? testy1-state)) "test1 is not goal")

(defn search [state]
  (var min-score math/inf)
  (def goals @[])
  (var counter 0)
  (def counter-limit 1e9)
  (defn walk [st n]
    (if (> counter counter-limit) (break))
    (++ counter)
    (if (goal? st)
      (let [new-score (st :score)]
        (printf " solution found %j ; counter=%j" new-score counter)
        (array/push goals (freeze st))
        (if (< new-score min-score)
          (set min-score new-score))))
    (loop [move :in (moves st)]
      (let [new-state (make-move st ;move)]
        (if (< (new-state :score) min-score)
          (walk new-state (inc n))))))
  (walk state 0)
  (printf "Finished search or hit max : %j solutions, %j positions examined"
          (length goals) counter)
  min-score)

#(printf "example2 min is %j" (search example2-state))
(printf "day23 min is %j" (search day23-state))
