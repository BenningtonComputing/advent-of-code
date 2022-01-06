``--- 21.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/21

    $ time janet 21.janet 
    rolls-times-loser for test-case is 739785
    Day 21 Part 1 is 855624
    dirac-dice [roll universes] @[(3 1) (4 3) (5 6) (6 7) (7 6) (8 3) (9 1)]
    test-dirac-wins @{:one 444356092776315 :two 341960390180808}
    day21-dirac-wins @{:one 187451244607486 :two 183752194019471}
    Day 21 Part 2 187451244607486

    real  4m23.732s
    user  4m15.053s
    sys	  0m8.632s

 I expect that this could be sped up with some sort
 of memoization but haven't spent the time to think that through
 ... see my notes at the end.

-------------------------------------------------------``
(use ./utils)

# inputs/21.txt :
# Player 1 starting position: 4
# Player 2 starting position: 10
# ... I didn't bother writing something to parse the input,
# instead just put these numbers in.

(defn create-state [position1 position2]
  @{:one @{:space position1 :score 0} # player 1 status
    :two @{:space position2 :score 0} # player 2 status
    :whose-turn :one
    :rolls 0})

(def day21-state (create-state 4 10))
(def test-state (create-state 4 8))

(def next-turn {:one :two :two :one})

(defn create-deterministic-die []
  (generate [i :range [0 math/inf]] (inc (mod i 100))))
(defn roll [die] (resume die))

(def winning-score 1000)

(defn playing? [state]
  (and (< (.get state [:one :score]) winning-score)
       (< (.get state [:two :score]) winning-score)))

(defn add-wrap [x offset highest]
  (def new-x (mod (+ x offset) highest))
  (if (zero? new-x)
    highest
    new-x))

(defn play-game [state &opt die verbose]
  (default die (create-deterministic-die))
  (default verbose false)
  (while (playing? state)
    (def player (state :whose-turn))
    (def status (state player))
    (def dice [(roll die) (roll die) (roll die)])
    (set (status :space) (add-wrap (status :space) (+ ;dice) 10))
    (+= (status :score) (status :space))
    (+= (state :rolls) 3)
    (if verbose (printf "%j rolls ; player %j rolls %j has %j"
                        (state :rolls) player dice status))
    (set (state :whose-turn) (next-turn player))))

#(play-game test-state (create-deterministic-die) true)
# 3 rolls ; player :one rolls (1 2 3) has @{:space 10 :score 10} # verbose true
# 6 rolls ; player :two rolls (4 5 6) has @{:space 3 :score 3}
# 9 rolls ; player :one rolls (7 8 9) has @{:space 4 :score 14}
# 12 rolls ; player :two rolls (10 11 12) has @{:space 6 :score 9}
# ...
# 981 rolls ; player :one rolls (79 80 81) has @{:space 6 :score 986}
# 984 rolls ; player :two rolls (82 83 84) has @{:space 6 :score 742}
# 987 rolls ; player :one rolls (85 86 87) has @{:space 4 :score 990}
# 990 rolls ; player :two rolls (88 89 90) has @{:space 3 :score 745}
# 993 rolls ; player :one rolls (91 92 93) has @{:space 10 :score 1000}

(defn rolls-times-loser [state]
  (* (state :rolls)
     (min (.get state [:one :score])
          (.get state [:two :score]))))

(play-game test-state)
(printf "rolls-times-loser for test-case is %j"
        (rolls-times-loser test-state))

(play-game day21-state)
(printf "Day 21 Part 1 is %j" (rolls-times-loser day21-state))

# ------ part 2 ------------

# three rolls of the dice : 3*3*3 = 27 outcomes
# 1                 2                 3
# 1     2     3     1     2     3     1     2     3     
# 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 

(def dirac-dice
  (frequencies (seq [a :range [1 4]
                     b :range [1 4]
                     c :range [1 4]] (+ a b c))))
(printf "dirac-dice [roll universes] %j" (pairs dirac-dice))
# dirac-dice [roll copies] @[(3 1) (4 3) (5 6) (6 7) (7 6) (8 3) (9 1)]
# In other words
#  the dice roll total is 3 in 1 universe 
#  the dice roll total is 4 in 3 universes
#  the dice roll total is 5 in 6 universes
#  etc
# This is essentially a trinomial expansion,
# similar to the pythagorean triangle binomial coefficients

(def winning-score-2 21)
(defn winner [state]
  (cond 
     (>= (.get state [:one :score]) winning-score-2)  :one
     (>= (.get state [:two :score]) winning-score-2)  :two
     :continue))

#(printf "one roll of the dirac dice :")
#(loop [[total count] :pairs dirac-dice]
#  (printf "  %j copy of total %j" count total))

(defn new-state [position1 position2]
  @{:one @{:space position1 :score 0}
    :two @{:space position2 :score 0}
    :universes 1
    :whose-turn :one })

(defn clone-state [state]
  @{:one (table/clone (state :one))
    :two (table/clone (state :two))
    :universes (state :universes)
    :whose-turn (state :whose-turn)})

(defn next-state 
  "make a new state by updating this one with this roll"
  # If this state exists in u1 universes,
  # and the dirac roll happens in u2 universes,
  # then there will be u1*u2 universes with these values.
  #
  # TODO : memoize a version of this
  #
  [state roll universes]
  (def player (state :whose-turn))
  (def status (state player))
  (def result (clone-state state))
  (def result-status (result player))
  (set (result-status :space) (add-wrap (status :space) roll 10))
  (+= (result-status :score) (result-status :space))
  (*= (result :universes) universes)
  (set (result :whose-turn) (next-turn player))
  result)

(defn play-dirac
  "Play a game with dirac dice. Return number of wins for each player."
  [position1 position2]
  (def wins @{:one 0 :two 0})
  (defn next-turn [state]
    #(printf "state %j" state)
    (case (winner state)
      :one      (+= (wins :one) (state :universes))
      :two      (+= (wins :two) (state :universes))
      :continue (loop [[roll universes] :pairs dirac-dice]
                  (next-turn (next-state state roll universes)))))
  (next-turn (new-state position1 position2))
  wins)

#(def day21-state (create-state 4 10))
#(def test-state (create-state 4 8))

(def test-dirac-wins (play-dirac 4 8))
(printf "test-dirac-wins %j" test-dirac-wins)

(def day21-dirac-wins (play-dirac 4 10))
(printf "day21-dirac-wins %j" day21-dirac-wins)

(printf "Day 21 Part 2 %j" (max (day21-dirac-wins :one)
                                (day21-dirac-wins :two)))

# This works but is pretty slow; 4.5min on my M1 Pro laptop.
#
# There are only 100 different player positions,
# :one 1 to 10 , :two 1 to 10, so there should
# be a way to memoize something
#
# ... perhaps the results of one turn and the modifications;
# [position1 position2 whose-turn] ->
# [ [position1 position2 universes score-change] ... ]
#
# ... or just memoize next-state.
#
