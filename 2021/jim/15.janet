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

      real  0m16.489s
      user  0m16.324s
      sys   0m0.053s

This one was a lot of work.

I tried this several different ways; see misc/15-slow.janet for the gory
details. This last version uses both Djikstra's min-path algorithm
along with a min-heap, doing the whole thing in 16 sec.. (Without the
min-heap, Djikstra's worked in 4.5min.)

-------------------------------------------------------``
(use ./utils)
(import ./heap)

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

(defn top-left [grid] [1 1])                               # assumes border
(defn bot-right [grid] (point/subtract (shape grid) [2 2]))   # ditto

# I need to use Djikstra's algorithm for a "shortest-path" search
# extending a connected tree by closest which here means lowest total
# sum so far. Neighbors are not just (down right) but also other
# directions. Keep track of fringe (what we can get to on next step)
# and known (ones that we are sure we know the min distance.)  And use
# a min-heap (see ./heap.janet) to get the closest one in O(1) time.

(defn shortest-path
  "Djikstra's shortest path search on a graph"
  # assumes grid has a border
  [grid]
  (def start (top-left grid))
  (def goal (bot-right grid))
  (var node start)
  (def known @{start 0})      # @{point value}
  (def fringe @{})            # @{point best-value-so-far}
  (def min-heap (heap/new))   # keep track of closest next node
  (def backpath @{})          # @{node parent ...}
  (while (not= node goal)
    (loop [neighbor :in (neighbors4-in-grid grid node)]
      #(printf "neighbor is %j; not in know is %j"
      #	      neighbor (not (in? known neighbor)))
      (if (not (in? known neighbor))
	(do
	  (def old-distance (get fringe neighbor math/inf))
	  (def new-distance (+ (known node) (.get grid neighbor)))
	  (if (< new-distance old-distance)
	    (do # update fringe & min-heap
	      (put fringe neighbor new-distance)
	      (heap/push min-heap [neighbor new-distance]))))))
    (def [new-node new-distance] (heap/pop min-heap))
    (put known new-node new-distance)   # put this one into "known" dict
    (put fringe new-node nil)           # ... and remove it from "fringe" dict
    (put backpath new-node node)
    (set node new-node))
  (known goal))

(printf "shortest-path example-grid is %j" (shortest-path example-grid))
(print)

(def day15-text (slurp-input 15))
(def day15-grid (text15->grid day15-text))
(printf "Day 15 Part 1 is %j" (shortest-path day15-grid))

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


