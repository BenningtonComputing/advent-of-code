``--- 12.janet ---------------------------------------
  https://adventofcode.com/2021/day/12

      $ time janet 12.janet 
      number of paths in example is 10
      number of paths in larger example is 19
      Day 12 Part 1 is 3298
      number of paths in example is now 36
      number of paths in larger example is now 103
      Day 12 Part 2 is 93572

      real  0m1.661s
      user  0m1.637s
      sys   0m0.022s

-------------------------------------------------------``
(use ./utils)

(defn text->edges "return [(node1 node2) (node3 node4) ...]" [text]
  (map (fn [line] (map keyword (string/split "-" line)))
       (text->lines text)))
(defn text->graph "return @{node neighbors ...}" [text]
  (edges->graph (text->edges text)))

(defn uppercase? "is this string all uppercase?" [str]
  (all (fn [x] (<= (chr "A") x (chr "Z")))
       (string/bytes str)))

(defn big? [node] (uppercase? (string node)))
(defn small? [node] (not (uppercase? (string node))))
(assert (big? :A) "check big")
(assert (small? :b) "check small")

(defn make-paths [graph &opt node path visited paths]
  (default node :start)
  (default path @[])
  (default paths @[])
  (default visited (make-set []))
  (array/push path node)
  (if (= node :end)
    (array/push paths (tuple ;path))
    (do
      (if (small? node)
	(set/add visited node))
      (loop [neighbor :in (graph node)]
	(if (not (member? visited neighbor))
	  (make-paths graph neighbor
		      (array ;path) (set/clone visited) paths)))))
  paths)

(def example-text (string/trim
``
start-A
start-b
A-c
A-b
b-d
A-end
b-end
``))
(def example-graph (text->graph example-text))
#(pp example-graph)
(def example-paths (make-paths example-graph))
(printf "number of paths in example is %j" (length example-paths))

(def larger-text (string/trim
``
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc
``))
(def larger-graph (text->graph larger-text))
(def larger-paths (make-paths larger-graph))
(printf "number of paths in larger example is %j" (length larger-paths))

(def day12-text (string/trim (slurp-input 12)))
(def day12-graph (text->graph day12-text))
(def day12-paths (make-paths day12-graph))
(printf "Day 12 Part 1 is %j" (length day12-paths))

# --- part 2 ------------------------------------------

(defn make-paths-2 [graph &opt node path visited twice paths]
  (default node :start)
  (default path @[])
  (default paths @[])
  (default visited (make-set [:start]))
  (default twice false)
  (array/push path node)
  (if (= node :end)
    (array/push paths (tuple ;path))
    (do
      (if (small? node)
	(set/add visited node))
      (loop [neighbor :in (graph node)]
	(if (not (member? visited neighbor))
	  (make-paths-2 graph neighbor (array ;path)
			(set/clone visited) twice paths)
	  (if (and (not twice) (not (= neighbor :start)))
	    (make-paths-2 graph neighbor (array ;path)
			  (set/clone visited) true paths))))))
  paths)

(def example-paths-2 (make-paths-2 example-graph))
(printf "number of paths in example is now %j" (length example-paths-2))
#(loop [p :in example-paths-2] (pp p))

(def larger-paths-2 (make-paths-2 larger-graph))
(printf "number of paths in larger example is now %j" (length larger-paths-2))

(def day12-paths-2 (make-paths-2 day12-graph))
(printf "Day 12 Part 2 is %j" (length day12-paths-2))
