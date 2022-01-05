``--- 19.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/19

      $ time janet 19.janet 
      Day 19 data has 30 scanners which altogether see 773 beacons.
      The number of distinct line segment distances is 7025
       Example: First four [0 25] overlap distances : (2858 13867 15570 16646)
         ... which correspond to : 'distance (scanner beacon1 beacon2)'
         2858  @[(0 1 16) (25 0 25)] 
         13867  @[(0 17 22) (10 1 12) (25 16 18)] 
         15570  @[(0 17 21) (10 0 1) (25 18 24)] 
         16646  @[(0 0 25) (10 6 25) (25 13 17)] 
         and their overlapping beacons are 
         scanner  0 : @[1 16 17 22 21 0 25 14 4 7 5 19]
         scanner 25 : @[0 25 16 18 24 13 17 14 4 5 23 20]
      aligning all scanner regions ...
      Day 19 Part 1 is 350
      Day 19 Part 2 is 10895

      real  0m1.200s
      user  0m1.172s
      sys   0m0.027s

 I spent *way* too long on this, trying to find various ways
 to determine what was going on without doing brute force
 searches, looking for unique signatures of clumps of points
 from their mutual distances. It all eventually worked, but
 I made my data structures too complicated and ended up getting
 lost in my train of thought a number of times. Lots of printing
 (now embedded here in comments) and lots of tool sharpening 
 without just heading for the goal.

-------------------------------------------------------``
(use ./utils)

(def day19-text (slurp-input 19))

(defn scanner-number [line]
  (scan-number (first (peg/match '(* "--- scanner " (<- :d+)) line))))

(defn beacon-coords [line]
  (map scan-number (string/split "," line)))

(defn parse19 [text]
  # return scanner and beacon data in this form :
  # @[  @{ :id 0 :beacons @[x1 y1 z1] @[x2 y2 z2] ...}
  #     @{ :id 1 :beacons ...}
  #  ]
  (def scanners @[])
  (var scanner nil)
  (def lines (reverse (text->lines text))) # reversed so I can "pop" 'em.
  (while (def line (array/pop lines))
    (if (string/find "scanner" line)
      (do
	(set scanner @{:id (scanner-number line) :beacons @[]})
	(array/push scanners scanner)))
    (if (string/find "," line)
      (array/push (scanner :beacons) (beacon-coords line))))
  scanners)

(def day19-scanners (parse19 day19-text))
(printf "Day 19 data has %j scanners which altogether see %j beacons."
        (length day19-scanners)
        (+ ;(seq [scanr :in day19-scanners] (length (scanr :beacons)))))

#(printf "number of scanners in day19 is %j" (length day19-scanners))
# number of scanners in day19 is 30
#(def scanner0 (day19-scanners 0))
#(defn get-beacons [n &opt scanners]
#  (default scanners day19-scanners)
#  ((scanners n) :beacons))
#(def beacons0 (get-beacons 0))
#(printf "Day 19:")
#(prinf " first scanner has id %j; %j beacons" (scanner0 :id) (length beacons0))
#(printf " %j ... %j" (first beacons0) (last beacons0))
#(printf " all %j scanners see total of %j beacons (including repeats)"
#        (length day19-scanners)
#        (+ ;(seq [s :in day19-scanners] (length (s :beacons)))))
# first scanner has id 0; 26 beacons @[-837 -546 895] ... @[-863 -517 772]

(defn pythdiffsq
  "square of pythagorean distance between two vectors"
  [vector1 vector2]
  (let [diff (.subtract1D vector1 vector2)]
    (dot1D diff diff)))

#(defn signature
#  "closest 11 squared pythagorean distances"
#  [scanner-index beacon-index &opt scanners]
#  (default scanners day19-scanners)
#  (let [scanner (scanners scanner-index)
#	beacons (scanner :beacons)
#	beacon (beacons beacon-index)]
#    (slice
#     (take 12 (sort (map (fn [b] (pythdiffsq beacon b)) beacons)))
#     1 -1)))
#
#(defn print-signature [s b n]
#  (printf "s=%j b=%j sig %j"
#	  s b (take n (signature s b))))

#(loop [s :range [0 30]]
#  (loop [b :range [0 (length (beacons s))]]
#    (prin "signature ")
#    (print-signature s b 6)))
#

# Let's think about how identifying pairs of points
# by using the distance between them,
# which will let us find corresponding pairs of points.
#
#       -- 1 ------  (a b c d e f) 6 elements, 6*5/2=15pairs
#       a b c d e f g h i
#           ----- 2 ----- (c d e f g h i) 7 elements, 7*6/3=21pairs
#       
# shared region [c d e f] : 4*3/2=6pairs 
#
# From number of shared pairs, we can deduce number of points in
# shared region, and from that we can get the total number of points.

(defn distances 
  "all squared pythagorean distance pairs"
  [scanner-index &opt scanners]
  (default scanners day19-scanners)
  (def beacons ((scanners scanner-index) :beacons))
  (seq [[i j] :in (index-pairs (length beacons))]
       (pythdiffsq (beacons i) (beacons j))))

(defn overlap
  "list of distances which are common to two scanners"
  [s1 s2 &opt scanners]
  (default scanners day19-scanners)
  (def dists1 (distances s1 scanners))
  (def dists2 (distances s2 scanners))
  (sort (set->array (intersection ;(map make-set [dists1 dists2])))))

#(defn print-overlap [s1 s2]
#  (printf "overlap (%j %j) is %j"
#	  s1 s2 (overlap s1 s2)))

# -- OK, let's think about distances between points as
#    a signature for a pair of points (i.e. a segment)
# If two regions have 12 overlapping points,
# then those 12 points form 12*11/2=66 pairs,
# and so those regions should have at least 66 distances in common.
#(loop [i :range [0 29]
#       j :range [(inc i) 30]]
#  (def count-overlap (length (overlap i j)))
#  (if (>= count-overlap 66)
#    (printf " scanners [%j %j] have %j distances in common" i j count-overlap)))
 # scanners [0 25] have 66 distances in common
 # scanners [1 4] have 67 distances in common
 # scanners [1 20] have 66 distances in common
 # scanners [2 17] have 66 distances in common
 # scanners [2 19] have 66 distances in common
 # scanners [2 20] have 66 distances in common
 # scanners [2 27] have 66 distances in common
 # scanners [3 19] have 66 distances in common
 # scanners [3 27] have 66 distances in common
 # scanners [4 7] have 66 distances in common
 # scanners [4 9] have 66 distances in common
 # scanners [4 26] have 66 distances in common
 # scanners [5 12] have 66 distances in common
 # scanners [5 17] have 66 distances in common
 # scanners [5 19] have 66 distances in common
 # scanners [6 15] have 66 distances in common
 # scanners [6 16] have 66 distances in common
 # scanners [7 12] have 66 distances in common
 # scanners [7 15] have 66 distances in common
 # scanners [7 19] have 66 distances in common
 # scanners [7 20] have 66 distances in common
 # scanners [8 18] have 66 distances in common
 # scanners [9 15] have 66 distances in common
 # scanners [9 21] have 66 distances in common
 # scanners [10 25] have 66 distances in common
 # scanners [11 12] have 66 distances in common
 # scanners [11 15] have 66 distances in common
 # scanners [11 21] have 66 distances in common
 # scanners [11 24] have 66 distances in common
 # scanners [12 13] have 66 distances in common
 # scanners [12 29] have 66 distances in common
 # scanners [13 17] have 66 distances in common
 # scanners [13 20] have 66 distances in common
 # scanners [13 23] have 66 distances in common
 # scanners [14 16] have 66 distances in common
 # scanners [15 22] have 66 distances in common
 # scanners [16 22] have 66 distances in common
 # scanners [16 28] have 66 distances in common
 # scanners [18 21] have 66 distances in common
 # scanners [23 25] have 66 distances in common
 # scanners [24 29] have 66 distances in common

# The fact that there's a 67 in there suggests
# to me that there are a few different pairs
# with the same distance ... which is entirely possible.

# So I can compile a 
#  { distance [ [scanner-id beacon-id1 beacon-id2] ...]     }
# ... that should allow us to go backwards from distances to points.

(defn segment-table
  " return table @{ distance @[ (scnr p1 p2) ...] ... }
    giving distances and the corresponding line segments"
  # Each line segment (scnr p1 p2) is two points within one scanner;
  # the distance is its pythagorean squared length.
  [scanners]
  (def result @{})
  (loop [scanner :in scanners]
    (def beacons (scanner :beacons))
    (seq [[i j] :in (index-pairs (length beacons))]
         (def distance (pythdiffsq (beacons i) (beacons j)))
         (if-not (get result distance)
           (put result distance @[]))
         (def points (get result distance))
         (array/push points [(scanner :id) i j])))
  result)

(def day19-segments (segment-table day19-scanners))
#(pp day19-segments)
(printf "The number of distinct line segment distances is %j" (length day19-segments))
#(def segment-distance-counts (map length (values day19-segments)))
#(printf " Number of point pairs is %j" (+ ;segment-distance-counts))
#(printf " Distance frequencies are %j"
#        (sort (pairs (frequencies segment-distance-counts))))

(defn overlap-segments
  "return the subset of the day19-segment table in the overlap of two scanners"
  [scanner1 scanner2]
  (mapcat (fn [d] (day19-segments d)) (overlap scanner1 scanner2)))

# Let's look at that 67 scanner 1 to 4 overlap more closely.
#(loop [d :in (take 3 (overlap 1 4))]
#  (printf " distance %j , points %j " d (day19-segments d)))
#(pp (overlap-segments 1 4))
# @[(1 20 25) (4 3 25) (7 6 19) ... (4 6 19) (1 10 25) (4 3 19)]
#
# counts of beacon id's in scanner 1's overlap with scanner 4 :
#(pp (frequencies (seq [s :in (overlap-segments 1 4)
#                         :when (= 1 (s 0))] ;[(s 1) (s 2)])))
#  @{1 11 2 11 6 11 7 11 8 1 10 11 11 11 12 11 14 12 18 11 20 11 21 11 25 11}
# ... and we see that they're all 11 (as they should be with 12 in overlap)
# except beacon 8, which only appears once, and 14, which appears 12 times.
# So it looks like the distance from beacon 8 to beacon 14 in scanner 1
# has the same distance as one in the 12 point overlap; that is,
# there is one extra line segment in scanner 1 which has the
# same length as some extra line segment in scanner 4.

(defn overlap-beacons
  "return id's of beacons in scanner s1 which overlap with scanner s2"
  [s1 s2]
  (def overlap-s1-s2 (overlap-segments s1 s2)) # @{ distance @[ [s b1 b2] ..]}
  (def beacons1 (seq [ [id count] :in
                        (pairs (frequencies (seq [s :in overlap-s1-s2
                                                  :when (= s1 (s 0))]
                                                 ;[(s 1) (s 2)])))
                      :when (>= count 11)] id))
  beacons1)
#(printf "beacons in scan 1 overlapping 4 : %j" (overlap-beacons 1 4))
#(printf "beacons in scan 4 overlapping 1 : %j" (overlap-beacons 4 1))
#  => beacons in scan 1 overlapping 4 : @[20 25 21 1 7 11 14 2 6 12 10 18]
#     beacons in scan 4 overlapping 1 : @[3 25 6 12 18 4 22 2 7 24 19 11]
# ... though I don't quite yet know which point corresponds to which
# other point; I know each segments endpoints in the two scanners
# (a,b) and (a',b'), but don't know the correct order.

# And I can also remember which scanners are adjacent to other scanners.

(defn make-neighbors [scanners]
  " create @{ :points @{ distance @[ [s p1 p2] [s p1 p2] ... ] ...}
              :neighbors @{ s1 @[s2 s3]  
            } "
  (def n (length scanners))
  (def result @{:points @{}
                :neighbors (map-table (fn [x] [x @[]]) (range n))})
  (loop [i :range [0 (dec n)]   # i'th scanner
         j :range [(inc i) n]]  # j'th scanner, i < j
    (def overlap-i-j (overlap i j scanners))
    (if (>= (length overlap-i-j) 66)
      (do
        (array/push ((result :neighbors) i) j)
        (array/push ((result :neighbors) j) i)
        (put (result :points) [i j] overlap-i-j)
        (put (result :points) [j i] overlap-i-j))))
  result)
(def day19-graph (make-neighbors day19-scanners))
#(printf "Day19 overlapping scanners:\n%M" (day19-graph :neighbors))
# i.e. for each scanner, list of scanners which overlap it
# Day19 overlapping scanners:
# @{0 @[25]
#   1 @[4 20]
#   2 @[17 19 20 27]
#   3 @[19 27]
#   4 @[1 7 9 26]
#   ...
#   25 @[0 10 23]
#   26 @[4]
#   27 @[2 3]
#   28 @[16]
#   29 @[12 24]}
(def four-0-25 (take 4 ((day19-graph :points) [0 25])))
# i.e. for each distance, list of [scanner-id point-id point-id] 
(printf " Example: First four [0 25] overlap distances : %j" four-0-25)
(printf "   ... which correspond to : 'distance (scanner beacon1 beacon2)'")
(loop [d :in four-0-25]
  (printf "   %j  %j " d (day19-segments d)))
# Example: First four [0 25] overlap distances : (2858 13867 15570 16646)
# ... which correspond to : 'distance (scanner beacon1 beacon2)'
# 2858  @[(0 1 16) (25 0 25)] 
# 13867  @[(0 17 22) (10 1 12) (25 16 18)] 
# 15570  @[(0 17 21) (10 0 1) (25 18 24)] 
# 16646  @[(0 0 25) (10 6 25) (25 13 17)] 

# So this narrows things down quite a bit. That last printout says
# for example that there are two points a distance 2858 apart which in
# the overlap between scanner 0 and 25, which can match
# (scanner beacon beacon) in only one of two ways :
# (0 1 16) is either (25 0 25) or (25 25 0).

(printf "   and their overlapping beacons are ")
(printf "   scanner  0 : %j" (overlap-beacons 0 25))
(printf "   scanner 25 : %j" (overlap-beacons 25 0))

# ---------

# OK, so now I need to deal with the rotations.
#
# 24 orientations : flip a pair, change the sign on one of 'em
# (x,y,z)   (x,z,-y)   (x,-y,-z)   (x,-z,y)
# (y,z,x)   (y,x,-z)   (y,-z,-x)   (y,-x,z)
# (z,x,y)   (z,y,-x)   (z,-x,-y)   (z,-y,x)
# (-x,z,y)  (-x,y,-z)  (-x,-z,-y)  (-x,-z,y)
# (-y,x,z)  (-y,z,-x)  (-y,-x,-z)  (-y,-z,x)
# (-z,y,x)  (-z,x,-y)  (-z,-y,-x)  (-z,-x,y)
# probably simplest with matrix multiplications
#   xyz       x,z,-y     x,-y,-z   x,-z,y
#   1 0 0     1  0  0    1  0  0   1  0  0
#   0 1 0     0  0  1    0 -1  0   0  0 -1   ... which is the top row
#   0 0 1     0 -1  0    0  0 -1   0  1  0

# rotation matrices e.g. cube group generators.
# The product of four of 'em is enough to get the group.
(def I [[1 0 0] [0 1 0] [0 0 1]])
(def Rx [[1 0 0] [0 0 1] [0 -1 0]]) # 90 around x axis; flip y,z & negate one.
(def Ry [[0 0 1] [0 1 0] [-1 0 0]]) # 90 around y axis
(def Rz [[0 1 0] [-1 0 0] [0 0 1]]) # 90 around z axis
(def generators [I Rx Ry Rz])
(def tmp @[])
(loop [a :in generators
       b :in generators
       c :in generators
       d :in generators]
  (array/push tmp (matrix-immutable (dot a (dot b (dot c d))))))
(def cube-group (distinct tmp)) # 24 3x3 rotation matrices
#(printf "Number of rotation matrices is %j" (length rotations))
#  Number of rotation matrices is 24
#(loop [r :in cube-group] (pp r))
#  ((1 0 0) (0 1 0) (0 0 1))
#  ((1 0 0) (0 0 1) (0 -1 0))
#  ((0 0 1) (0 1 0) (-1 0 0))
#  ((0 1 0) (-1 0 0) (0 0 1))
#  ((1 0 0) (0 -1 0) (0 0 -1))
#  ((0 0 1) (-1 0 0) (0 -1 0))
#  ((0 1 0) (0 0 1) (1 0 0))
#  ((0 -1 0) (0 0 1) (-1 0 0))
#  ((-1 0 0) (0 1 0) (0 0 -1))
#  ((0 1 0) (0 0 -1) (-1 0 0))
#  ((-1 0 0) (0 -1 0) (0 0 1))
#  ((1 0 0) (0 0 -1) (0 1 0))
#  ((0 0 1) (0 -1 0) (1 0 0))
#  ((0 1 0) (1 0 0) (0 0 -1))
#  ((0 -1 0) (-1 0 0) (0 0 -1))
#  ((-1 0 0) (0 0 -1) (0 -1 0))
#  ((-1 0 0) (0 0 1) (0 1 0))
#  ((0 0 -1) (0 -1 0) (-1 0 0))
#  ((0 0 -1) (0 1 0) (1 0 0))
#  ((0 -1 0) (1 0 0) (0 0 1))
#  ((0 0 1) (1 0 0) (0 1 0))
#  ((0 -1 0) (0 0 -1) (1 0 0))
#  ((0 0 -1) (-1 0 0) (0 1 0))
#  ((0 0 -1) (1 0 0) (0 -1 0))

(defn transform [x y z dx dy dz rot]
  (dot (cube-group rot) (.add1D [x y z] [dx dy dz])))

# -------------

(defn point-matches
  "return (pt1 pt2a pt2b) such that the point 
   (scn1 pt1) matches either (scn2 pt2a) or (scn2 pt2b)"
  [scn1 scn2]
  (def result @[nil nil nil])
  (loop [[scn p1 p2] :in (day19-segments (first (overlap scn1 scn2)))]
    (if (= scn scn1) (put result 0 p1))
    (if (= scn scn2) (do (put result 1 p1) (put result 2 p2))))
  result)

(defn point-in-segment?
  "true if the point (scn1 pt1) 
   is one of the endpoints of the segment [scn2 pt2a ptb]"
  [scn1 pt1 [scn2 pt2a pt2b]]
  (and (= scn1 scn2)
       (or (= pt1 pt2a)
           (= pt1 pt2b))))

(defn distances-from-endpoint
  "return list of distances that have given [scanner point] at one end"
  [scn pt]
  (def result @[])
  (loop [[distance segments] :pairs day19-segments]
    (loop [seg :in segments]
      (if (point-in-segment? scn pt seg) (array/push result distance))))
  (tuple ;(sorted result)))

(defn which-match
  [scn1 pt1 scn2 pt2a pt2b]
  (def d1 (make-set (distances-from-endpoint scn1 pt1)))
  (def d2a (make-set (distances-from-endpoint scn2 pt2a)))
  (def d2b (make-set (distances-from-endpoint scn2 pt2b)))
  #(printf "1 to 2a : size of overlap is %j"
  #       
  #(printf "1 to 2b : size of overlap is %j"
  #       (length (intersection d1 d2b)))
  (if (> (length (intersection d1 d2a))
         (length (intersection d1 d2b)))
    pt2a
    pt2b))

# -----------

(defn scnr-bcn
  " [x y z] for scanner index s and beacon index b "
  [scnr bcn]
  (((day19-scanners scnr) :beacons) bcn))

(defn beacon-indices
  " indices for beacons of given scanner "
  [scnr]
  (indices ((day19-scanners scnr) :beacons)))

# ** aligned coords ** of all scanners and beacons : part 1
(def aligned-coords @[])  # @[ [x y z] [x y z] ... ]  ## includes duplicates
# same as above but as a "set" data structure, without duplicates : part 2
(def aligned-set (make-set []))
# matching each orginal (scanner beacon) point to id in aligned-coords : part 3
(def aligned-lookup @{})  # @{ [scnr bcn] coord-id ... }
(def aligned-scanners @[ [0 0 0] ]) # aligned coords for each scanner

(defn add-coord [xyz scnr bcn]
  " add xyz to aligned-coords, aligned-set, aligned-lookup "
  (def tuple-xyz (tuple ;xyz))
  (array/push aligned-coords tuple-xyz)
  (set/add aligned-set tuple-xyz)
  (put aligned-lookup [scnr bcn] (last-index aligned-coords)))
  
# Put scnr 0's beacons into the aligned coords 
(loop [b :in (beacon-indices 0)]
  (add-coord (scnr-bcn 0 b) 0 b))

(defn rotate-points-around [rot-index points center]
  (def zeroed (map (fn [p] (.subtract1D p center)) points))
  (def rotated (map (fn [p] (dot (cube-group rot-index) p)) zeroed))
  (map (fn [p] (tuple ;(.add1D p center))) rotated))

(defn count-duplicate-points 
  "return number of points which are same as those in aligned coords"
  [points]
  (length (intersection (make-set points) aligned-set)))

(defn add-shifted-scanner
  "add a scanner position to the aligned-scanners list of coordinates"
  [offset rot-index center]
  (def shifted (.add1D offset [0 0 0]))
  (def rotated (rotate-points-around rot-index [shifted] center))
  (array/push aligned-scanners (rotated 0)))

(defn shift
  "translate and rotate beacon1's points, and add to aligned coords, 
   moving the point [scnr1 bcn1] to [scnr2 bcn2] and rotating appropriately "
  [scnr1 bcn1 scnr2 bcn2]
  (var result nil)
  (def destination (aligned-coords (aligned-lookup [scnr2 bcn2])))
  #(printf "destination is %j" destination)
  (def dxyz (.subtract1D destination (scnr-bcn scnr1 bcn1))) # offset
  (def new-points (tuple ;((day19-scanners scnr1) :beacons)))
  #(printf "new-points is %j" new-points)
  (def shifted-points (map (fn [p] (.add1D dxyz p)) new-points))
  #(printf "shifted-points is %j" shifted-points)
  (loop [i :in (indices cube-group)]
    (def rotated (rotate-points-around i shifted-points destination))
    #(print)
    #(printf "rotated %j" rotated)
    #(printf " with rotation %j on (%j %j) -> (%j %j), %j duplicates"
    #       i scnr1 bcn1 scnr2 bcn2 (count-duplicate-points rotated))))
    (if (> (count-duplicate-points rotated) 10)
      (do (set result rotated)
          (add-shifted-scanner dxyz i destination)
          (break))))
  result)

(defn transfer [old-scn new-scn]
  #(prinf " have %j , next %j ;" old-scn new-scn)
  (def [pt1 pt2a pt2b] (point-matches old-scn new-scn))
  (def pt2 (which-match old-scn pt1 new-scn pt2a pt2b))
  #(printf "   shift either (%j %j) or (%j %j) to (%j %j)"
  #        new-scn pt2a new-scn pt2b old-scn pt1))
  #(printf "   shift (%j %j) to (%j %j)" new-scn pt2 old-scn pt1)
  (def aligned-points (shift new-scn pt2 old-scn pt1))
  (loop [i :in (indices aligned-points)]
    (add-coord (aligned-points i) new-scn i)))

(defn join-scanners [graph]
  #(printf "joining scanners...")
  (def remaining (make-set (keys (graph :neighbors))))
  (def fringe @[])
  (var previous-current [nil 0])
  (while (not-empty? remaining)
    (def current (second previous-current))
    (set/remove remaining current)
    (loop [neighbor :in ((graph :neighbors) current)]
      (array/push fringe [current neighbor]))
    (while (not-empty? fringe)
      (set previous-current (array/pop fringe))
      (if (member? remaining (second previous-current)) (break)))
    (if (member? remaining (second previous-current))
      (transfer ;previous-current))))

(printf "aligning all scanner regions ...")
(join-scanners day19-graph)

# joining scanners...
#  have 0 , next 25 ;   shift (25 0) to (0 1)
#  have 25 , next 23 ;   shift (23 15) to (25 7)
#  have 23 , next 13 ;   shift (13 14) to (23 11)
#  have 13 , next 20 ;   shift (20 1) to (13 14)
#  have 20 , next 7 ;   shift (7 1) to (20 9)
#  have 7 , next 19 ;   shift (19 8) to (7 2)
#  have 19 , next 5 ;   shift (5 4) to (19 8)
#  have 5 , next 17 ;   shift (17 17) to (5 10)
#  have 17 , next 2 ;   shift (2 10) to (17 6)
#  have 2 , next 27 ;   shift (27 22) to (2 3)
#  have 27 , next 3 ;   shift (3 14) to (27 3)
#  have 5 , next 12 ;   shift (12 3) to (5 4)
#  have 12 , next 29 ;   shift (29 6) to (12 1)
#  have 29 , next 24 ;   shift (24 24) to (29 4)
#  have 24 , next 11 ;   shift (11 20) to (24 8)
#  have 11 , next 21 ;   shift (21 13) to (11 20)
#  have 21 , next 18 ;   shift (18 7) to (21 14)
#  have 18 , next 8 ;   shift (8 0) to (18 9)
#  have 21 , next 9 ;   shift (9 25) to (21 14)
#  have 9 , next 15 ;   shift (15 24) to (9 4)
#  have 15 , next 22 ;   shift (22 24) to (15 18)
#  have 22 , next 16 ;   shift (16 22) to (22 18)
#  have 16 , next 28 ;   shift (28 20) to (16 12)
#  have 16 , next 14 ;   shift (14 16) to (16 13)
#  have 16 , next 6 ;   shift (6 5) to (16 12)
#  have 9 , next 4 ;   shift (4 16) to (9 0)
#  have 4 , next 26 ;   shift (26 6) to (4 9)
#  have 4 , next 1 ;   shift (1 25) to (4 3)
#  have 25 , next 10 ;   shift (10 18) to (25 2)

# (pp (overlap-beacons 0 25))
# @[1 16 17 22 21 0 25 14 4 7 5 19]

# (pp (overlap 0 25))
# @[2858 13867 15570 ...

# (pp (day19-segments 2858))
# @[(0 1 16) (25 0 25)]  

#(printf "(distances-from-endpoint 25 0) %j"
#        (distances-from-endpoint 25 0))
#(printf "(distances-from-endpoint 25 25) %j"
#        (distances-from-endpoint 25 25))
#(printf "(distances-from-endpoint 0 1) %j"
#        (distances-from-endpoint 0 1))
# (distances-from-endpoint 25 0) (2858 26882 639782 654939 682577 795989 ...
# (distances-from-endpoint 25 25) (2858 30158 689689 723294 733165 825561 ...
# (distances-from-endpoint 0 1) (2858 26882 639782 654939 871796 896882 ...

#(which-match 0 1 25 0 25)
# 1 to 2a : size of overlap is 11
# 1 to 2b : size of overlap is 1

#(printf "scanner 0 : %j"
#        ((day19-scanners 0) :beacons))
#(printf "aligned : %j"
#        aligned-coords)

#(print)
#(printf "(shift  25 0  0 1)")
#(print)
#(printf "%j" (shift 25 0 0 1))

(printf "Day 19 Part 1 is %j" (length aligned-set))

# --- part 2 ----

#(printf "Day 19 Part 2 is %j"
#        (max ;(map (fn [p] (manhattan (p 0) (p 1)))
#                   (array->pairs (set/members aligned-set)))))
# Day 19 Part 2 is 14889 ... wrong ; too high.

# Not how far apart do the *beacons* get;
# the question is how far apart the *scanners* get.

(printf "Day 19 Part 2 is %j"
        (max ;(map (fn [p] (manhattan (p 0) (p 1)))
                   (array->pairs aligned-scanners))))



