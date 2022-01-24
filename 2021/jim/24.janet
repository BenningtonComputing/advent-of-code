``--- 24.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/24

      $ time janet 24.janet 
      MONAD has 252 instructions in 14 sections, each with 18 similar lines.
      @["inp w" "mul x 0" "add x z" ... "add y 10" "mul y x" "add z y"]
      Number of valid ws found is 11760.
      Day 24 Part 1 is 39494195799979
      Day 24 Part 2 is 13161151139617

      real  0m9.855s
      user  0m9.446s
      sys   0m0.406s

I spent a *long* time on this ... about two weeks playing around with
occasionally.  Turns out I had a typo in my transcription of the
constants (turned an 8 into an 18) that gave me the wrong answer,
even though I had the correct method.

-------------------------------------------------------``
(use ./utils spork)

# The MONAD program input 24.txt has 14 similar sections, each
# starting with "inp w" which reads 1 digit into register w each with
# 18 lines including the first "inp w".

(def MONAD (text->lines (slurp-input 24)))
(printf "MONAD has %j instructions in 14 sections, each with 18 similar lines." (length MONAD))
(pp MONAD)

(defn monad-grid [m]
  (map |(slice-n m (* $ 18) 18) (range 14)))

(defn print-mg [mg]
  (loop [line :range [0 18]]
    (loop [chunk :range [0 14]]
      (let [code (.get mg [chunk line])]
        (prinf "%-8s | " code)))
    (print)))

#(print-mg (monad-grid MONAD))

# ## 0 ##    ## 1 ##    ## 2 ##    ## 3 ##    ## 4 ##    ## 5 ##    ## 6 ##    ## 7 ##    ## 8 ##    ## 9 ##    ## 10 ##   ## 11 ##   ## 12 ##   ## 13 ##        
# inp w    | inp w    | inp w    | inp w    | inp w    | inp w    | inp w    | inp w    | inp w    | inp w    | inp w    | inp w    | inp w    | inp w    | 
# mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | mul x 0  | 
# add x z  | add x z  | add x z  | add x z  | add x z  | add x z  | add x z  | add x z  | add x z  | add x z  | add x z  | add x z  | add x z  | add x z  | 
# mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 | mod x 26 |
# div z 1  | div z 1  | div z 1  | div z 1  | div z 26 | div z 1  | div z 1  | div z 26 | div z 1  | div z 26 | div z 26 | div z 26 | div z 26 | div z 26 |   *** 
# add x 13 | add x 15 | add x 15 | add x 11 | add x -7 | add x 10 | add x 10 | add x -5 | add x 15 | add x -3 | add x 0  | add x -5 | add x -9 | add x 0  |   ***
# eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | eql x w  | 
# eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | eql x 0  | 
# mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | 
# add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | add y 25 | 
# mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | 
# add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | add y 1  | 
# mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | mul z y  | 
# mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | mul y 0  | 
# add y w  | add y w  | add y w  | add y w  | add y w  | add y w  | add y w  | add y w  | add y w  | add y w  | add y w  | add y w  | add y w  | add y w  | 
# add y 6  | add y 7  | add y 10 | add y 2  | add y 15 | add y 8  | add y 1  | add y 10 | add y 5  | add y 3  | add y 5  | add y 11 | add y 12 | add y 10 |   ***
# mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | mul y x  | 
# add z y  | add z y  | add z y  | add z y  | add z y  | add z y  | add z y  | add z y  | add z y  | add z y  | add z y  | add z y  | add z y  | add z y  | 

# ----------------          -- translation --
#   inp w                    w = input()
#   mul x 0                  x = 0                  # first mention of x, so not carried over
#   add x z                  x = x + z = 0 + z = z  # z = z_in carried over from previous iteration; 0 first time
#   mod x 26                 x = z mod 26                      #        0  1  2  3  4  5  6  7  8  9 10 11 12 13
#   div z 1                  z = floor( z / C1 )               # C1 = [ 1  1  1  1 26  1  1 26  1 26 26 26 26 26 ]  #  z unchanged (C1==1), or z=floor(z_in/C1)
#   add x 13                 x' = x + C2 = (z_in mod 26) + C2  # C2 = [13 15 15 11 -7 10 10 -5 15 -3  0 -5 -9  0 ]
#   eql x w                  x = (x'==w ? 1 : 0)
#   eql x 0                  x = (x==0 ? 1 : 0) = (x'==w? 0 : 1)  =>   xs = { 0 or 1 }  , 0 iff w_input = (z_input mod 26) + C2
#   mul y 0                  y = 0                  # first mention of y, so not carried over
#   add y 25                 y = y + 25 = 25
#   mul y x                  y = y * x = 25 * x     # where x = (x'==w? 0 : 1) => y = (x'=w? 0 : 25)                # y = 0 or 25
#   add y 1                  y = y + 1                                                                              # y = { 1 if w_in=[(z_in mod 26)+C2] else 26 }
#   mul z y                  z = z * y = floor(z_in/C1) * y                                                         # z2 = floor(z_in/C1) * {1 or 26} 
#   mul y 0                  y = 0                  # reset to 0
#   add y w                  y = y + w = 0 + w = w           #        0  1  2  3  4  5  6  7  8  9 10 11 12 13      # y  = w_in
#   add y 6                  y = y + C3 = w + C3             # C3 = [ 6  7 10  2 15 18  1 10  5  3  5 11 12 10 ]    # y  = w_in + C3
#   mul y x                  y = y * xs             # where x = (x'==w? 0 : 1)                                      # y2 = { 0 if w_in=[...] else w_in + C3 }
#   add z y                  z = z + y = z_out = z1 + y1 = floor(z_in/C1) * {1 or 26} + { 0 or (w_in +C3) } = floor(z_in/C1) or { 26 * floor(z_in/C1) + w_in + C3 }

#         *  *  *  *     *  *     *
#         0  1  2  3  4  5  6  7  8  9 10 11 12 13
(def C1 [ 1  1  1  1 26  1  1 26  1 26 26 26 26 26 ])
(def C2 [13 15 15 11 -7 10 10 -5 15 -3  0 -5 -9  0 ])       
(def C3 [ 6  7 10  2 15  8  1 10  5  3  5 11 12 10 ])      # BUG!!! Had 18 (wrong) instead of 8 (correct) for (C3 5)

(defn MD1 [w z c1 c2 c3]
  #(def match (+ c2 (mod z 26)))                   # w = c2+(z mod 26) or not
  #(def x_switch (if (= w match) 0 1))             # 0                 or 1 
  #(def y_switch (+ 1 (* 25 x_switch)))            # 1                 or 26
  #(def z1 (math/floor (/ z c1)))
  #(def z2 (* y_switch z1))                        # z1                or (26 * z1)
  #(def y2 (* x_switch (+ w c3)))                  # 0                 or (w+c3)
  #(def z3 (+ y2 z2))                              # z1                or (26 * floor(z/c1)) + (w+c3)
  #z3
  #
  (if (= w (+ c2 (mod z 26)))                      # ... all that boils down to just this.
    (math/floor (/ z c1))
    (+ w c3 (* 26 (math/floor (/ z c1))))))

(defn MD1i [w z i] (MD1 w z (C1 i) (C2 i) (C3 i)))  # MD for round i , input w,z => output z

(defn MD [ws]
  #(printf " w = %j " ws)
  (var z 0)
  #(prinf  " z = [")
  (loop [i :range [0 14]]
    (set z (MD1i (ws i) z i))
    #(prinf "%j " z))
    #(printf "]"))
    )
  z)

# So on the rounds where c=1, (a) match>9 and so x_switch = 1, therefore (b) z ~ 26 * z => exponential growth.
# Let's guess that on the other rounds, where c1=26, that we need to go in the opposite direction,
# i.e. that we need w to match the condition, if possible. This may cut the search space (all 14 w values 1 -> 9)
# down to a size that we can search for those values where z14=0, and find the largest w.

(defn search-long []
  (def result @[])
  (defn search-i [ws z i]
    (if (= i 14)
      (if (= z 0) (array/push result ws))        # Found valid sequence of ws; save it.
      (if (= 1 (C1 i))                           # Possible to choose special w value?
        (for w 1 10                               # no - loop over all w, continue search
          (let [zz (MD1i w z i)]
            (search-i [;ws w] zz (inc i))))
        (let [w-hopeful (+ (C2 i) (mod z 26))]   # maybe - find special w value
          (if (< 0 w-hopeful 10)                 #   Is special value in range 1 to 9 inclusive?
            (let [w w-hopeful                    #   yes - continue search using that w
                  zz (MD1i w z i)]
              (search-i [;ws w] zz (inc i)))
            (for w 1 10                          #   no - try all w values
              (let [zz (MD1i w z i)]
                (search-i [;ws w] zz (inc i)))))))))
  (search-i [] 0 0)
  result)

(defn ws->number [ws &opt power-of-ten number]
  (def _ws (array ;ws))
  (default power-of-ten 1)
  (default number 0)
  (if (empty? _ws)
    number
    (let [w (array/pop _ws)
          new-power (* 10 power-of-ten)
          new-number (+ number (* power-of-ten w))]
      (ws->number _ws new-power new-number))))
(assert (= 1234 (ws->number [1 2 3 4])))

#(def ws-found (search))
#(printf "Number of valid ws found is %j." (length ws-found))
#(printf "Largest w is %j" (max ;(map ws->number ws-found)))

# --- putting w=1 each time there is no w_special
# $ time janet 24.janet 
# time janet 24.janet 
# MONAD has 252 instructions in 14 sections, each with 18 similar lines.
# @["inp w" "mul x 0" "add x z" ... "add y 10" "mul y x" "add z y"]
# Number of valid ws found is 8820.
# Largest w is 39394995791979         WRONG - too low    ... but I had a bug in my C3 values. 
# real	0m8.820s
# user	0m8.478s
# sys	0m0.337s

# --- looping over all w=1..9 each there is no w_special ... this is the search-long version
# $ time janet 24.janet 
# time janet 24.janet 
# MONAD has 252 instructions in 14 sections, each with 18 similar lines.
# @["inp w" "mul x 0" "add x z" ... "add y 10" "mul y x" "add z y"]
# Number of valid ws found is 8820.
# Largest w is 39394995791979
# 
# real	540m52.952s
# user	530m5.397s
# sys	10m43.087s
            
# Hmmm.
# I think that I need to consider more carefully the pattern
# of how z grows and shrinks with the c2=1 vs c2=26 rounds.
# Perhaps I can get away with one (or more?) not w_special values.
#
# I should think of z as a base 26 number (using letters?);
# then the two cases are
#  c1=26  if w = w_special;  z ->  int(z/26) ; so       z=ABCD => z=0ABC  i.e. z has 1 less digit
#         if not          ;  z -> 26*int(z/26) + (w+c3) z=ABCD => z=ABCE  i.e. rightmost replaced
#  c1=1   c2>9, not special; z -> 26*z + (w+c3)         z=ABCD => z=ABCDE i.e. z has 1 more digit
#
# If we don't use w_special, maybe instead replace the rightmost with a 0?

# (defn MD1 [w z c1 c2 c3]         # one round [ w z ] => z
#   (if (= w (+ c2 (mod z 26)))
#     (math/floor (/ z c1))
#     (+ w c3 (* 26 (math/floor (/ z c1))))))

# base 26
#  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  Z
#  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23

# w = 1 2 3 4 5 6 7 8 9
#     B C D E F G H I J
#     H I J K L M N O P   (w+6)     = z after round 1
#     I J K L M N O P Q   (w+7)
#     L M N O P Q R S T   (w+10)
#     D E F G H I J K L   (w+2)

# C=1  => grow z
# C=26 => shrink z or replace rightmost
#
# XXXX'   =>  chose to replace rather than shrink once
# XXXX''  =>  chose to replace rather than shrink twice

# round   C1  C2  C3    z_out_base26 ... format outline
# -----   --  --  --    -----------------------------
#  0       1  13   6    B        B is min H=7=1+6, max P=15=9+6, so not zero
#  1       1  15   7    BC       C is min I=8=1+7, max Q=17=9+7
#  2       1  15  10    BCD
#  3       1  11   2    BCDE
#  4      26  -7  15    BCD    or                BCDF'
#  5       1  10  18    BCDG   or                BCDFG'   ### here w=8 => G=0 mod 26    NO!!!! this should be 8, not 18!
#  6       1  10   1    BCDGH  or                BCDFGH'
#  7      26  -5  10    BCDG   or  BCDGI'   or   BCDFG'   or  BCDFGJ''
#  8       1  15   5    BCDGK  or  BCDGIK'  or   BCDFGK'  or  BCDFGJK''
#  9      26  -3   3    BCDG   or  BCDGI'
# 10      26   0   5    BCD    or  BCDG'
# 11      26  -5  11    BC     or  BCD'
# 12      26  -9  12    B      or  BC'
# 13      26   0  10    0      or  B' ... is there a way to get this to be zero??   Hmmm. I don't see it ... so why is my answer wrong??

# ============== *** OOPS *** - found bug in my C3 values!  Let's go back to the "shrink every time" approach.

(defn search []
  (def result @[])
  (defn search-i [ws z i]
    (if (= i 14)
      (if (= z 0) (array/push result ws))        # Found valid sequence of ws; save it.
      (if (= 1 (C1 i))                           # Possible to choose special w value?
        (for w 1 10                              #   no - loop over all w :
          (let [zz (MD1i w z i)]                 #          Find next z.
            (search-i [;ws w] zz (inc i))))      #          Continue search.
        (let [w-maybe (+ (C2 i) (mod z 26))      #   maybe - find special w value
              w (if (< 0 w-maybe 10) w-maybe 1)  #     Can special w be 1 to 9? If not, w=1 and let it fail.
              zz (MD1i w z i)]                   #          Find next z.
          (search-i [;ws w] zz (inc i))))))      #          Continue search
  (search-i [] 0 0)
  result)

(def ws-found (search))
(printf "Number of valid ws found is %j." (length ws-found))
(def ws-largest (max ;(map ws->number ws-found)))
(printf "Day 24 Part 1 is %j" ws-largest)  # ... which is the right answer.

# =======================================================================

(def ws-smallest (min ;(map ws->number ws-found)))
(printf "Day 24 Part 2 is %j" ws-smallest) # ... which is also correct.


             
  
  
              
           
