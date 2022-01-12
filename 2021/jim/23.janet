``--- 23.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/23


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

# -----------------------------------------------

# The input for part 2 looks like this :

# example
(def example2-text ``
#############
#...........#
###B#C#B#D###
  #D#C#B#A#
  #D#B#A#C#
  #A#D#C#A#
  #########
``)
  
(def day22part2-text ``
#############
#...........#
###C#A#B#D###
  #D#C#B#A#
  #D#B#A#C#
  #D#C#A#B#
  #########
``)  

#############
#...........#      y=0
###C#A#B#D###      y=1
  #D#C#B#A#        y=2
  #D#B#A#C#        y=3
  #D#C#A#B#        y=4
  #########
#0123456789A       x = 0 to 10
#  A B C D         home columns

(def hallx [0 1 3 5 7 9 10])
(def hally 0)
(def roomx [2 4 6 8])
(def roomy [1 2 3 4])

#(def home {:A 2 :B 4 :C 6 :D 8})
#(def apods (seq [type :in [:A :B :C :D] id :in (range 4)] [type id]))
#(def cells [;(seq [x :in hallx] [x 0])                # top row
#            ;(seq [x :in roomx y :in roomy] [x y])])  # 4 columns
(defn initialize-state [text]
  (def lettergrid (text->lines # e.g. @["BCBD" "DCBA" "DBAC" "ADCA"]
                   (string/trim
                    (string/replace-all-many
                     text ["." "" "*" "" "#" "" " " ""]))))
  (def result @{ :score 0 :at (from-pairs (seq [x :in hallx] [[x hally] :.]))})
  (loop [row :range [0 4] col :range [0 4]]
    (put (result :at) [(roomx col) (inc row)]
         (keyword (string/nth (lettergrid row) col))))
  result)

(def example2-state (initialize-state example2-text))
# (printf "%M" example2-state)
# @{:at @{
#     (0 0) :.
#     (1 0) :.
#     (2 1) :B
#     (2 2) :D
#     (2 3) :D
#     (2 4) :A
#     (3 0) :.
#     (4 1) :C
#     (4 2) :C
#     (4 3) :B
#     (4 4) :D
#     (5 0) :.
#     (6 1) :B
#     (6 2) :B
#     (6 3) :A
#     (6 4) :C
#     (7 0) :.
#     (8 1) :D
#     (8 2) :A
#     (8 3) :C
#     (8 4) :A
#     (9 0) :.
#     (10 0) :.} :score 0}

(defn empty? [state [x y]] (= ((state :at) [x y]) :.))

(defn top-in-room [state room]
  (def index (find (fn [i] (not (empty? state [room i]))) [1 2 3 4]))
  (if index
    [room index]
    nil))

(defn moves [state]
  # a move is [[x1 y1] [x2 y2]]
  # only two sorts of moves :
  #  (a) from one of its starting columns to somewhere in the top row,
  #      if the path between is empty, or
  #  (b) from a place in the top row to its final home column,
  #      if the path between is empty, and
  #      if there are no incorrect apods in the final home column
  (def result @[])
  # (a) : look for highest in each room
  (loop [rx :in roomx]
    (def move-from (top-in-room state rx))
    (if move-from
      
  
  
