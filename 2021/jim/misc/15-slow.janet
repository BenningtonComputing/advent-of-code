``--- 15.janet ---------------------------------------
  https://adventofcode.com/2021/day/14

      $ time janet 15.janet 
      -- example grid --
      1163751742
      1381373672
      2136511328
      3694931569
      7463417111
      1319128137
      1359912421
      3125421639
      1293138521
      2311944581

      shortest-path example-grid is 40

      Day 15 Part 1 is 527

      -- big example grid --
      11637517422274862853338597396444961841755517295286
      13813736722492484783351359589446246169155735727126
      21365113283247622439435873354154698446526571955763
      36949315694715142671582625378269373648937148475914
      74634171118574528222968563933317967414442817852555
      13191281372421239248353234135946434524615754563572
      13599124212461123532357223464346833457545794456865
      31254216394236532741534764385264587549637569865174
      12931385212314249632342535174345364628545647573965
      23119445813422155692453326671356443778246755488935
      22748628533385973964449618417555172952866628316397
      24924847833513595894462461691557357271266846838237
      32476224394358733541546984465265719557637682166874
      47151426715826253782693736489371484759148259586125
      85745282229685639333179674144428178525553928963666
      24212392483532341359464345246157545635726865674683
      24611235323572234643468334575457944568656815567976
      42365327415347643852645875496375698651748671976285
      23142496323425351743453646285456475739656758684176
      34221556924533266713564437782467554889357866599146
      33859739644496184175551729528666283163977739427418
      35135958944624616915573572712668468382377957949348
      43587335415469844652657195576376821668748793277985
      58262537826937364893714847591482595861259361697236
      96856393331796741444281785255539289636664139174777
      35323413594643452461575456357268656746837976785794
      35722346434683345754579445686568155679767926678187
      53476438526458754963756986517486719762859782187396
      34253517434536462854564757396567586841767869795287
      45332667135644377824675548893578665991468977611257
      44961841755517295286662831639777394274188841538529
      46246169155735727126684683823779579493488168151459
      54698446526571955763768216687487932779859814388196
      69373648937148475914825958612593616972361472718347
      17967414442817852555392896366641391747775241285888
      46434524615754563572686567468379767857948187896815
      46833457545794456865681556797679266781878137789298
      64587549637569865174867197628597821873961893298417
      45364628545647573965675868417678697952878971816398
      56443778246755488935786659914689776112579188722368
      55172952866628316397773942741888415385299952649631
      57357271266846838237795794934881681514599279262561
      65719557637682166874879327798598143881961925499217
      71484759148259586125936169723614727183472583829458
      28178525553928963666413917477752412858886352396999
      57545635726865674683797678579481878968159298917926
      57944568656815567976792667818781377892989248891319
      75698651748671976285978218739618932984172914319528
      56475739656758684176786979528789718163989182927419
      67554889357866599146897761125791887223681299833479


      shortest-path big-example-grid is 315

      Day 15 Part 2 is 2887

      real  4m37.002s
      user  4m36.018s
      sys   0m0.692s

-------------------------------------------------------``
(use ./utils)

(def example-text 
``
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
``)

(defn text15->grid
  "convert text to grid with border"
  [text]
  (add-border (text->grid text) math/inf))

(def example-grid (text15->grid example-text))
(print "-- example grid --")
(print-grid example-grid)

(defn .down  [[row col]] [(inc row) col])
(defn .up    [[row col]] [(dec row) col])
(defn .right [[row col]] [row (inc col)])
(defn .left  [[row col]] [row (dec col)])

(defn above? [[row1 col1] [row2 col2]] (= col1 col2))
(defn beside? [[row1 col1] [row2 col2]] (= row1 row2))

(defmacro go-down [grid point goal total]
  # defined with a macro rather than a function because of mutual recursion;
  # otherwise, min-path-1 needs to be already defined.
  ~(let [pt (.down ,point)
	ttl (+ ,total (.get ,grid pt))]
    (min-path-1 ,grid pt ,goal ttl)))

(defmacro go-right [grid point goal total]
  ~(let [pt (.right ,point)
	ttl (+ ,total (.get ,grid pt))]
    (min-path-1 ,grid pt ,goal ttl)))

# example: original     [[1 2 3] [4 5 6]]  # shape (2 3)
#          with border  [[9 9 9 9 9] [9 1 2 3 9] [9 4 5 6 9] [9 9 9 9 9]] # shape (4 5)
#                       top-right is (1 1) ; bottom left is (2 3) i.e. - 2 from shape

(defn top-left [grid] [1 1])                               # assumes border
(defn bot-right [grid] (point/subtract (shape grid) [2 2]))   # ditto

(defn min-path-1 [grid &opt point goal total]
  # 1st try: down or right, all branches
  (default point (top-left grid))
  (default goal (bot-right grid))
  (default total 0)
  (cond
    (= point goal) total
    (above? point goal) (go-down grid point goal total)
    (beside? point goal) (go-right grid point goal total)
    (min
     (go-down grid point goal total)
     (go-right grid point goal total))))

# This works. On a 10x10 example grid, tree is about 2**10 ~ 1000
#(printf "min-path-1 on example gives %j" (min-path-1 example-grid))

# but it's *much* too slow ...
# the input grid is 100x100 ; 2**100 is 1267650600228229401496703205376 .
#  (def day15-grid (add-border (text->grid (slurp-input 15)) 9))
#  (printf "Day 15 Part 1 is %j" (min-path-1 day15-grid))

# 2nd attempt: use the approach from the projecteuler pyramid;
# best out to each successive nested rectangle,
# adding in smallest of above vs left
#
#    0123
#    1123
#    2223
#    3333
#
#    025   in this order ; use the border to avoid thinking about edges
#    137
#    468
#

(defn min-at-point
  "add to grid point smaller of above & left point"
  [grid point]
  (.put grid point
	(+ (.get grid point)
	   (min (.get grid (.up point))
		(.get grid (.left point))))))

(defn minimize-grid
  "replace each grid point with smaller of above & left"
  # order is (a) by layers as per left array below,
  # then within each layer by the (b) pattern.
  #   (a)     (b)
  #  99999                       i j
  #  91234        2   layer 4 : (4 1) (1 4) (4 2) (2 4) (4 3) (3 4) (4 4)
  #  92234        4             1     2     3     4     5     6     7
  #  93334        6 
  #  94444     1357
  # Since we don't want to include the point at (1 1),
  # we need to (i) do the point at (2 2), then (ii) loop from row 3.
  [grid]
  (def new-grid (grid-clone grid))
  (min-at-point new-grid [2 2])
  (loop [i :range-to [3 (.bottom grid)]]
    (loop [j :range-to [1 i]]
      (min-at-point new-grid [i j])
      (if-not (= i j)
	(min-at-point new-grid [j i]))))
  new-grid)

(def minimized-example (minimize-grid example-grid))
#(print "-- minimized example --")
#(print-grid-spacey minimized-example)

(defn min-path-2
  "minimize, return bottom right value"
  [grid]
  (.get (minimize-grid grid) (bot-right grid)))

#(printf "min-path-2 on example gives %j"
#	(min-path-2 example-grid))

#(def day15-grid (text15->grid (slurp-input 15)))
#(printf "Day 15 Part 1 is %j"
#	(min-path-2 day15-grid))
# gave 531 ... which is incorrect.

# Let's try the same sort of approach
# but with a different order,
# going through successive diagonals , starting at (4 5 6) :
#
#    1 3 6 a . . .     The 4x4 case looks like this.
#    2 5 8 d . .       The . are entries outside; skip.
#    4 8 c f .
#    7 b e g
#    . . .
#    . .
#    .
#
# (1 1)
# (2 1) (1 2)
# (3 1) (2 2) (1 3)
# (4 1) (3 2) (2 3) (1 4)
#       (4 2) (3 3) (2 4)   # (5 1) is past edge; skip
#
# Hmmm. But suppose the best path isn't monotomically down or right?
# It isn't hard to come up with configurations with 1's along a twisty
# path and 9's elseshere. So this won't work either.
#
# I need to use Djikstra's and do a real "shortest-path" search,:
# extending a connected tree by *closest* which here means lowest total
# sum so far.  Neighbors are not just (down right) but also other
# directions.  Keep track of fringe (what we can get to on next step)
# and known (ones that we are sure we know the min distance.)

(defn heap-push [heap key value] )
(defn heap-pop [heap] )
  

(defn shortest-path
  "Djikstra's shortest path search on a graph"
  # assumes grid has a border
  [grid]
  (def start (top-left grid))
  (def goal (bot-right grid))
  (var node start)
  (def known @{start 0})      # @{point value}
  (def fringe @{})            # @{point best-value-so-far}
  (def backpath @{})          # @{node parent ...}
  (while (not= node goal)
    (loop [neighbor :in (neighbors4-in-grid grid node)]
      #(printf "neighbor is %j; not in know is %j"
      #	      neighbor (not (in? known neighbor)))
      (if (not (in? known neighbor))
	(put fringe neighbor (min (get fringe neighbor math/inf)
				  (+ (known node) (.get grid neighbor))))))
    (def [new-node new-distance] (dict/find-min fringe))
    (if-not new-node (error "no path to goal"))
    (put known new-node new-distance)
    (put fringe new-node nil) # removing it
    (put backpath new-node node)
    #(printf "new-node is %j, distance is %j, parent is %j"
    # 	    new-node new-distance node)
    #(printf "fringe is %j" fringe)
    #(printf "known is %j" known) 
    (set node new-node))
  (known goal))

# 3rd different approach to solving this :
(printf "shortest-path example-grid is %j" (shortest-path example-grid))
(print)

(def day15-text (slurp-input 15))
(def day15-grid (text15->grid day15-text))
(printf "Day 15 Part 1 is %j" (shortest-path day15-grid))
# ... and that is correct (in 1.8sec)

# If I need to speed up for part 2, the next step would be to
# implement a min-meap for the fringe to turn the O(n) search for
# smallest to O(1).

(defn wrap9 [x] (def y (mod x 9)) (if (= 0 y) 9 y))

(defn text15->biggrid
  "convert text to 5x bigger grid, with border around whole thing"
  [text]
  (def grid0 (text->grid text))
  (def [rows0 cols0] (shape grid0))
  (def grid5 (grid-fill (point/scale 5 [rows0 cols0]) 0))
  (loop [r :range [0 5]
	 c :range [0 5]
	 row :range [0 rows0]
	 col :range [0 cols0]]
    (def y (+ row (* rows0 r)))
    (def x (+ col (* cols0 c)))
    (.put grid5 [y x] (wrap9 (+ r c (.get grid0 [row col])))))
  (add-border grid5 math/inf))

(def big-example-grid (text15->biggrid example-text))
(print)
(print "-- big example grid --")
(print-grid big-example-grid)
(print)
(printf "shortest-path big-example-grid is %j" (shortest-path big-example-grid))
(print)

(def big-day15-grid (text15->biggrid day15-text))
(printf "Day 15 Part 2 is %j" (shortest-path big-day15-grid))
# ... which is slow (4.5 min), but gave the right answer.

# TODO : speed up with min-heap.
