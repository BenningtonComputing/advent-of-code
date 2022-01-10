``--- 22.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/22

  $ time janet 22.janet 
  number of cubes on in larger example is 590784
  Day 22 Part 1 is 609563
  test1 count is 39
  consider this count is 2758514936282235
  Day 22 Part 2 is 1234650223944734

  real  0m17.986s
  user  0m17.777s
  sys   0m0.208s

 Part 2 took me a long time, and I went through a lot of
 variations of trying to combine cubes. My first several 
 attempts were too complicated and too slow, though the
 general ideas were not too far off from what I did eventually.
 I was happy about the final simplification: adding two cuboids
 is the same as subtracting them, then adding one back in whole.

-------------------------------------------------------``
(use ./utils spork)

(def test1-text ``
  on x=10..12,y=10..12,z=10..12
  on x=11..13,y=11..13,z=11..13
  off x=9..11,y=9..11,z=9..11
  on x=10..10,y=10..10,z=10..10 ``)

(defn parse-line [line]
  (def items
    (regex/match
     ``(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)``
     (string/trim line)))
  (def on-off (keyword (items 0)))
  (def values (map scan-number (slice items 1 -1)))
  {:what on-off :low [(values 0) (values 2) (values 4)]
                :high [(values 1) (values 3) (values 5)]})
  
(defn parse22
  "array of @{:high [x1 y1 z1] :low [x2 y2 z2] :what :on|:off}"
  [text]
  (map parse-line (text->lines text)))

#(pp (parse22 test1-text))

(def region-offsets [-50 -50 -50])
(def region-sizes [101 101 101])
(def region-values {:on 1 :off 0})

(defn ixyz [xyz] (.subtract1D xyz region-offsets))

(defn new-region [&opt sizes value]
  (default sizes region-sizes)
  (default value 0)
  (seq [:repeat (sizes 0)]
       (seq [:repeat (sizes 1)]
            (seq [:repeat (sizes 2)] value))))

#(def test-region (new-region [2 2 2] 0))
#(.put test-region [1 1 1] 7)
#(pp test-region)

(def larger-example-text ``
  on x=-20..26,y=-36..17,z=-47..7
  on x=-20..33,y=-21..23,z=-26..28
  on x=-22..28,y=-29..23,z=-38..16
  on x=-46..7,y=-6..46,z=-50..-1
  on x=-49..1,y=-3..46,z=-24..28
  on x=2..47,y=-22..22,z=-23..27
  on x=-27..23,y=-28..26,z=-21..29
  on x=-39..5,y=-6..47,z=-3..44
  on x=-30..21,y=-8..43,z=-13..34
  on x=-22..26,y=-27..20,z=-29..19
  off x=-48..-32,y=26..41,z=-47..-37
  on x=-12..35,y=6..50,z=-50..-2
  off x=-48..-32,y=-32..-16,z=-15..-5
  on x=-18..26,y=-33..15,z=-7..46
  off x=-40..-22,y=-38..-28,z=23..41
  on x=-16..35,y=-41..10,z=-47..6
  off x=-32..-23,y=11..30,z=-14..3
  on x=-49..-5,y=-3..45,z=-29..18
  off x=18..30,y=-20..-8,z=-3..13
  on x=-41..9,y=-7..43,z=-33..15
  on x=-54112..-39298,y=-85059..-49293,z=-27449..7877
  on x=967..23432,y=45373..81175,z=27513..53682 ``)

# To do these operations fast, I should be using some sort of bit array.
# Then the "on" and "off" operations would be setting integers to 0
# or (bnot 0). Janet has bit operations for 32-bit integers
# (the docs are confusing, and numeric types are all :number even
# though (int? i) is only true for 32-bit ints, and the bit operations
# blshift, band, bnot, bxor, etc all only work (and wrap) on 32-bit ints.

# But for a first attempt, I'll just use 3D arrays of 0's and 1's.

(defn execute
  "apply each step to region sequentially"
  # brute force ..
  [region steps]
  (def [ixmax iymax izmax] (shape region))
  (loop [{:what what :low xyz-low :high xyz-high} :in steps]
    (def [ixlo iylo izlo] (ixyz xyz-low))
    (def [ixhi iyhi izhi] (ixyz xyz-high))
    (def value (region-values what))  # 0 or 1
    (if (and (< ixlo ixmax) (> ixhi 0)
             (< iylo iymax) (> iyhi 0)
             (< izlo izmax) (> izhi 0))
      (loop [ix :range-to [ixlo ixhi]
             iy :range-to [iylo iyhi]
             iz :range-to [izlo izhi]]
        (.put region [ix iy iz] value))))
  region)

(def larger-example-result
  (execute (new-region) (parse22 larger-example-text)))
(printf "number of cubes on in larger example is %j"
        (sum (flatten larger-example-result)))

(def day22-text (slurp-input 22))
(def day22-result1 (execute (new-region) (parse22 day22-text)))
(printf "Day 22 Part 1 is %j" (sum (flatten day22-result1)))

# --- part 2 ---

# Lots bigger regions. And a huge sum. I think I need another approach.
#
# I'm not sure that bit arithmetic will be enough of a speedup.
#
# Maybe some sort of higher level abstraction?
# Something to do with the size of overlaps between pairs of steps?
# An algebra of rectangular solid intersections?
#
# in 2D :
#                  +-----+             +--+--+....  
#                  |     |             |  |  |   .                           
#                  |  *--.---*         +--+--+---+
#                  |  |  |   |  =>     |  |  |   |
#                  +--.--+   |         +--+--+---+
#                     |      |         .  |  |   |
#                     *------*         ...+--+---+
#
#    +------+      +------+
#    |      |      | | |  |
#    | *-*  |      +-+-+--+          Looks like I can always think
#    | | |  | =>   | | |  |          of this as a 3x3 grid of smaller
#    | *-*  |      +-+-+--+          cuboids, as long as I leave some out.
#    |      |      | | |  |
#    +------+      +-+-+--+
#
#      +------+                +---+--+...
#      |      |                |   |  |  .
#      |   *--.--*             +---+--+--+
#      |   |  |  |     =>      |   |  |  |
#      |   *--.--*             +---+--+--+
#      |      |                |   |  |  .
#      +------+                +---+--+...
#
#                  x1    x1           x1  x2 x1' x2''
#              y1  +-----+             +--+--+....     y1
#                  |     |             |  |  |   .                           
#                  |  +--.---+y2       +--+--+---+     y2
#                  |  |  |   |         |  |  |   |
#              y1' +--.--+   |         +--+--+---+     y1'
#                     |      |         .  |  |   |
#                     +------+y2'      ...+--+---+     y2'
#                     x2     x2'
#
# The trick I think may be to subdivide the originals into
# smaller rectangles, so that I only need to keep track
# of a collection of rectangular shaped non-overlapping regions.
#
# Each of the new smaller pieces will have interior coords
# which are either all on or all off. And each is entirely
# within one or more of the previous pieces.
#
# I do need to find some sort of algorithmic way to do this
# ... perhaps a recursion over a corner from each cuboid? Hmmm.
#
# Ah ha! It always a 27-cube grid, just as the ones above
# are all variations on the 9-square 3x3 grid.
#
# Now I just need to get the overlap in the middle values correct
#
#    (1) sort (xmin1 xmax1 xmin2 xmax2) to (x1 x2 x3 x4)
#    (2) in the centers, (x2', x2'') are (x2-1,x2) or (x2,x2+1)
#        depending on which way puts one of those outside one cuboid.
#        i.e. x1 -> x2' ; x2'' -> x3' ; x3'' -> x4
#    (3) same for y, z
#    (4) loop over each pair as low - high; check if in originals
#    (5) ... test some special cases.
#
# In 3D, I'll call these rectangular solids "cuboids".
# And what I need is an algebra of these things.
#
# I think that I only need keep track of the "on" cubes; once an "off"
# has done its thing, I can throw away the disjoint cuboids that aren't on.
#
# cuboids : @[ @{ :what on-or-off :high [x1 y1 zy] :low [x2 y2 z2]} ]
#
# When adding a "new" cuboid to a list [a b] of cuboids,
# the new one may overlap several of the old ones.
# Perhaps the simplest approach is to loop until the first
# overlap, then start again with those new smaller ones
# to see if they overlap with anything.
#
#  +a-----+    +---b--+         +-++---+    +--++--+    (a - new)
#  |  +---.----.--+   |   =>    | |+-----------+|  |    (b - new)
#  |  |   |    |  |   |         | ||           ||  |    new
#  +--.---+    |  |   |         +-+|           ||  |  
#     |        +--.---+            |           |+--+
#     +--new------+                +--new------+
#
# Ah ha!!
# My subtraction algorithm works fine combining one :off cuboid
# with many :on cuboids, because those many :on's are disjoint,
# and so I end up with many disjoints which don't interact.
# So the simple way to do addition is to treat it first as
# a subtraction (i.e. remove "new" from a,b,c,...)
# then at the end just add the entire "new" cuboid back in.

#(defn on? [c] (= :on (c :what)))
#(defn off? [c] (= :off (c :what)))

(defn low [cuboid i] ((cuboid :low) i))
(defn high [cuboid i] ((cuboid :high) i))
(defn low-high [cuboid i] [((cuboid :low) i) ((cuboid :high) i)])

# There are some special cases to handle in cuboid intersections
# if the edges align, thing like
#    +---+              +-----+
#    +---------+              +-------+
# will give overlapping cuboids with volume 1.
# Do I need to handle those case?
# Let's see if there are any duplicate values in the inputs.
#
#(defn duplicates1? [steps i]
#  (def values (flatten (seq [s :in steps] (low-high s i))))
#  (> (length values) (length (distinct values))))
#(defn duplicates? [text]
#  (def steps (parse22 text))
#  (any? (map |(duplicates1? steps $) (range 3))))
#(printf "duplicates in larger-example? %j" (duplicates? larger-example-text))
#
# ... so yes, there are some duplicate values.

(defn separate1? "true if in direction i, cuboids do not overlap" [c1 c2 i]
  #       +-------+          +--------+
  #       1low    1high      2low    2high
  (or (< (high c1 i) (low c2 i))
      (< (high c2 i) (low c1 i))))
(defn separate? "true if no overlap between two cuboids" [c1 c2]
  (or (nil? c1) (nil? c2)
      (any? (map |(separate1? c1 c2 $) [0 1 2]))))
(defn overlap? [c1 c2] (not (separate? c1 c2)))

#(defn inside? "is the corner xyz within the  cuboid?" [xyz cuboid]
#  (all |( <= ((cuboid :low) $) (xyz $) ((cuboid :high) )) (range 3)))
#(defn corners "return eight corners [[x1 y1 y2] ...] of cuboid" [c]
#  (seq [x :in (low-high c 0)
#        y :in (low-high c 1)
#        z :in (low-high c 2)] [x y z]))

#(defn subdivide-borders-n
#  "find [[low high] [low high] ..] non-overlapping subdivisions of n intervals"
  # [cuboids i]
  # #   +-----+                  +-+ +---+ +---+
  # #      +-------+     =>     +   +     +     +
  # #        +--------+
  # # To avoid complexities over which of the left vs right sides
  # # the border should be a part of, I'm putting all the borders
  # # (including the ends) into their own width 1 intervals.
  # (def xs (distinct (sort (seq [c :in cuboids] ;[(low c i) (high c i)]))))
  # (def result @[ [(xs 0) (xs 0)] ])       # start with leftmost width 1 edge
  # (loop [i :range [0 (dec (length xs))]]  # loop over i -> (i+1) i.e. x0 -> x3
  #   (let [x0 (xs i)                       #   x0 x1 ... x2 x3
  #         x1 (inc x0)                     #    .  +-----+  +      
  #         x3 (xs (inc i))                 
  #         x2 (dec x3)]
  #     (if (<= x1 x2) (array/push result [x1 x2]))  # x1 -> x2 interior
  #     (array/push result [x3 x3])))                # x3 -> x3 right edge
  # result)

#(defn overlap-any? [c cs] (any |(overlap? $ c) cs))

#(defn subdivide-n "return array of disjoint cuboids" [cs]
#  (def result (seq [[xlo xhi] :in (subdivide-borders-n cs 0)
#                    [ylo yhi] :in (subdivide-borders-n cs 1)
#                    [zlo zhi] :in (subdivide-borders-n cs 2)]
#                   @{:what :on :low [xlo ylo zlo] :high [xhi yhi zhi]}))
#  (filter  (fn [r] (overlap-any? r cs)) result))

(defn subdivide-borders
  "find [[low hi] [low hi] ...] borders of sub cuboids along axis i"
  [c1 c2 i]
  (def [c1-low c1-high] (low-high c1 i))
  (def [c2-low c2-high] (low-high c2 i))
  (cond
    (and (= c1-low c2-low) (= c1-high c2-high)) [[c1-low c1-high]]
    (= c1-low c2-low) (let [a c1-low                     # c1  +------+
                            b (min c1-high c2-high)      # c2  +---+
                            c (max c1-high c2-high)]     #     a   b  c
                          [[a b] [(inc b) c]])
    (= c1-high c2-high) (let [a (min c1-low c2-low)      # c1  +------+
                              b (max c1-low c2-low)      # c2     +---+
                              c c1-high]                 #     a  b   c
                          [[a (dec b)] [b c]])
    (let [[a b c d] (sort (array c1-low c2-low c1-high c2-high))]
      # There are these remaining possibilities for the overlap :
      #    c1  +-----+        +---------+      +----+       +----+
      #    c2      +----+       +----+       +--------+    +--+
      #        a   b c  d     a b    c  d    a b    c d    ab c  d
      #        1111222333     11222222333    1122222233    1222333
      # and in all those cases, 1 ends before 2, and 3 starts after 2.
      [[a (dec b)] [b c] [(inc c) d]])))

(defn subdivide "return array of disjoint cuboids that cover c1 & c2 " [c1 c2]
  # Only call this to get the subdivided pieces; the on-off stuff is
  # handled elswhere. So all new cuboids will be :on.
  (def cs (seq [[xlo xhi] :in (subdivide-borders c1 c2 0)
                [ylo yhi] :in (subdivide-borders c1 c2 1)
                [zlo zhi] :in (subdivide-borders c1 c2 2)]
               @{:what :on :low [xlo ylo zlo] :high [xhi yhi zhi]}))
  #(printf "subdivide: cs=%j" cs)
  (filter |(or (overlap? $ c1) (overlap? $ c2)) cs))

(defn subtract-cuboids "combine [:on :off] cuboids; keep :on" [c1-on c2-off]
  # We want the cuboids from c1 which are not in c2.
  (if (separate? c1-on c2-off)
    @[c1-on]
    (filter |(separate? $ c2-off) (subdivide c1-on c2-off))))

#(let [a {:what :on :high [12 12 12] :low [10 10 10]}
#      b {:what :on :high [13 13 13] :low [11 11 11]}
#      diff (subtract-cuboids a b)]
#  (printf "a=%j \nb=%j \n%j subtract-cuboids=\n%M" a b (length diff) diff))

# (defn add-one-many
#   "given disjoint cs, add c and subdivide as needed"
#   [cuboid cuboids]
#   ### Find all of the ones that overlap, and do the subdivision all at once.
#   (def no-overlap @[])
#   (def overlapping @[])
#   (loop [c :in cuboids]
#     (if (overlap? c cuboid)
#       (array/push overlapping c)
#       (array/push no-overlap c)))
#   (array ;no-overlap (subdivide-n [cuboid ;overlapping])))

(defn subtract-one-many "given disjoint cs, subtract a from each" [a cs]
  (distinct-freeze
   (array/concat @[] ;(seq [c :in cs] (subtract-cuboids c a)))))

(defn add-one-many "given disjoint cs, add a" [a cs]
  # new idea: subtract a from all overlaps, then just put it back in.
  (tuple a ;(subtract-one-many a cs)))

(defn reboot [text]
  (var result @[])
  (def steps (parse22 text))
  (var i 0)
  (loop [step :in steps]
    (++ i)
    #(prinf "step %j" step)
    #(printf " %j of %j, %j pieces" i (length steps) (length result))
    #(print)
    #(printf "result is %j" result)
    #(printf "step is %j" step)
    (set result (flatten      # ugh ... this is a kludge
                   (case (step :what)
                     :on  (add-one-many step result)
                     :off (subtract-one-many step result)))))
  result)

(defn size "size along axis i" [cuboid i]
  (inc (- (high cuboid i) (low cuboid i))))
(defn volume [cuboid] (product (map |(size cuboid $) (range 3))))
(defn count-on [cuboids] (sum (map volume cuboids)))

(def test1-cuboids (reboot test1-text))
#(printf "test1-cuboids\n%M" test1-cuboids)
(printf "test1 count is %j" (count-on test1-cuboids))  # 39 ; correct

(def consider-text ``
  on x=-5..47,y=-31..22,z=-19..33
  on x=-44..5,y=-27..21,z=-14..35
  on x=-49..-1,y=-11..42,z=-10..38
  on x=-20..34,y=-40..6,z=-44..1
  off x=26..39,y=40..50,z=-2..11
  on x=-41..5,y=-41..6,z=-36..8
  off x=-43..-33,y=-45..-28,z=7..25
  on x=-33..15,y=-32..19,z=-34..11
  off x=35..47,y=-46..-34,z=-11..5
  on x=-14..36,y=-6..44,z=-16..29
  on x=-57795..-6158,y=29564..72030,z=20435..90618
  on x=36731..105352,y=-21140..28532,z=16094..90401
  on x=30999..107136,y=-53464..15513,z=8553..71215
  on x=13528..83982,y=-99403..-27377,z=-24141..23996
  on x=-72682..-12347,y=18159..111354,z=7391..80950
  on x=-1060..80757,y=-65301..-20884,z=-103788..-16709
  on x=-83015..-9461,y=-72160..-8347,z=-81239..-26856
  on x=-52752..22273,y=-49450..9096,z=54442..119054
  on x=-29982..40483,y=-108474..-28371,z=-24328..38471
  on x=-4958..62750,y=40422..118853,z=-7672..65583
  on x=55694..108686,y=-43367..46958,z=-26781..48729
  on x=-98497..-18186,y=-63569..3412,z=1232..88485
  on x=-726..56291,y=-62629..13224,z=18033..85226
  on x=-110886..-34664,y=-81338..-8658,z=8914..63723
  on x=-55829..24974,y=-16897..54165,z=-121762..-28058
  on x=-65152..-11147,y=22489..91432,z=-58782..1780
  on x=-120100..-32970,y=-46592..27473,z=-11695..61039
  on x=-18631..37533,y=-124565..-50804,z=-35667..28308
  on x=-57817..18248,y=49321..117703,z=5745..55881
  on x=14781..98692,y=-1341..70827,z=15753..70151
  on x=-34419..55919,y=-19626..40991,z=39015..114138
  on x=-60785..11593,y=-56135..2999,z=-95368..-26915
  on x=-32178..58085,y=17647..101866,z=-91405..-8878
  on x=-53655..12091,y=50097..105568,z=-75335..-4862
  on x=-111166..-40997,y=-71714..2688,z=5609..50954
  on x=-16602..70118,y=-98693..-44401,z=5197..76897
  on x=16383..101554,y=4615..83635,z=-44907..18747
  off x=-95822..-15171,y=-19987..48940,z=10804..104439
  on x=-89813..-14614,y=16069..88491,z=-3297..45228
  on x=41075..99376,y=-20427..49978,z=-52012..13762
  on x=-21330..50085,y=-17944..62733,z=-112280..-30197
  on x=-16478..35915,y=36008..118594,z=-7885..47086
  off x=-98156..-27851,y=-49952..43171,z=-99005..-8456
  off x=2032..69770,y=-71013..4824,z=7471..94418
  on x=43670..120875,y=-42068..12382,z=-24787..38892
  off x=37514..111226,y=-45862..25743,z=-16714..54663
  off x=25699..97951,y=-30668..59918,z=-15349..69697
  off x=-44271..17935,y=-9516..60759,z=49131..112598
  on x=-61695..-5813,y=40978..94975,z=8655..80240
  off x=-101086..-9439,y=-7088..67543,z=33935..83858
  off x=18020..114017,y=-48931..32606,z=21474..89843
  off x=-77139..10506,y=-89994..-18797,z=-80..59318
  off x=8476..79288,y=-75520..11602,z=-96624..-24783
  on x=-47488..-1262,y=24338..100707,z=16292..72967
  off x=-84341..13987,y=2429..92914,z=-90671..-1318
  off x=-37810..49457,y=-71013..-7894,z=-105357..-13188
  off x=-27365..46395,y=31009..98017,z=15428..76570
  off x=-70369..-16548,y=22648..78696,z=-1892..86821
  on x=-53470..21291,y=-120233..-33476,z=-44150..38147
  off x=-93533..-4276,y=-16170..68771,z=-104985..-24507 ``)

(def consider-cuboids (reboot consider-text))
(printf "consider this count is %j" (count-on consider-cuboids))

(printf "Day 22 Part 2 is %j"
        (count-on (reboot day22-text)))
