``--- 17.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/17

      $ time janet 17.janet 
      example target is {:xmin 20 :ymin -10 :xmax 30 :ymax -5}
      day17 target is {:xmin 70 :ymin -179 :xmax 96 :ymax -124}
      example v=[7 2] result? :hit
      example highest y is 45 at vx=6 vy=9
      Day 17 Part 1 is 15931
      number of example solutions is 112
      Day 17 Part 2 is 2555

      real  0m0.300s
      user  0m0.292s
      sys   0m0.007s

-------------------------------------------------------``
(use ./utils)

(defn parse17 [text]
  (def [xmin xmax ymin ymax]
    (string-delim->ints ","
      (string/replace "target area: x=" ""
        (string/replace " y=" ""
  	  (string/replace-all ".." "," text)))))
  {:xmin xmin :xmax xmax :ymin ymin :ymax ymax})

(def example-text "target area: x=20..30, y=-10..-5")
(def example-target (parse17 example-text))
(printf "example target is %j" example-target)

(def day17-text (string/trim (slurp-input 17)))
(def day17-target (parse17 day17-text))
(printf "day17 target is %j" day17-target)

(defn new-probe [vx vy] @{:x 0 :y 0 :vx vx :vy vy :t 0})

(defn step [probe]
  (++ (probe :t))
  (+= (probe :x) (probe :vx))
  (+= (probe :y) (probe :vy))
  (if (> (probe :vx) 0) (-- (probe :vx)))
  (if (< (probe :vx) 0) (++ (probe :vx)))  
  (-- (probe :vy))
  probe)

(defn in-target? [probe target]
  (and (<= (target :xmin) (probe :x) (target :xmax))
       (<= (target :ymin) (probe :y) (target :ymax))))

(defn x-past? [probe target] (> (probe :x) (target :xmax)))
(defn y-past? [probe target] (< (probe :y) (target :ymin)))

(defn try [vx vy target]
  (var result :continue)
  (var highest math/-inf)
  (def probe (new-probe vx vy))
  (while (= result :continue)
    (step probe)
    (if (> (probe :y) highest) (set highest (probe :y)))
    (if (x-past? probe target) (set result :past-x))
    (if (and (= vx 0) (< (probe :x) (target :xmin))) (set result :low-x))
    (if (y-past? probe target) (set result :past-y))
    (if (in-target? probe target) (set result :hit)))
  {:highest highest :result result :x (probe :x) :y (probe :y)})

(defn success? [vx vy target]
  (def outcome (try vx vy target))
  (outcome :result))

(printf "example v=[7 2] result? %j" (success? 7 2 example-target))

# OK, so I need to search over some range of initial vx & vy.
# The x distance traveled is
#   t=1, x = vx
#   t=2, x = vx + (vx - 1)
#   t=3, x = vx + (vx - 1) + (vx - 2)
# So at t=vx, the distance is 1+2+3+...+vx = vx*(vx+1)/2 .
# And his must be at least xmin, or we don't reach the target;
# this gives a lowerbound on vx.
#
#   (a) vx*(vx+1)/2 >= xmin   
#       vx*vx + vx >= 2*xmin
#       vx ~ sqrt(2*xmin) looks like a reasonable place to start.
#
# At the other extreme, if vx is (xmax+1), then on the
# first step we jump right over the target ... so that
# gives us an upper bound on vx.
#
#   (b) vx <= xmax + 1
#
# For each vx, I then need to search over a range of vy values
# to find the one that lands in the target and has the highest y.
# Since one possible solution is (vx,vy)=(xmin,ymax), since that
# jumps to that corner in one step, I know that there is a (weak)
# solution with that ymax, which gives us a lower bound.
#
#   (c) vy > ymax
#
# For the upper bound on vy, I see that if y is above ymax
# when x is past xmax, then increasing vy will only make it
# even higher ... this is something that can be checked during
# the search as a place to stop.
#
#   (d) vy < (vy where y>ymax at x=xmax)

# (defn search
#   "loop over vx & vy looking for successful shots. Return highest y"
#   [target]
#   (var best {:y math/-inf})
#   (def vx-start (math/floor (math/sqrt (* 2 (target :xmin)))))
#   (def vx-end (inc (target :xmax)))
#   (def vy-start (target :ymax))
#   (loop [vx :range-to [vx-start vx-end]]
#     (var vy vy-start)
#     (var vy-looping? true)
#     (while vy-looping?
#       (def outcome (try vx vy target))
#       (if (= :hit (outcome :result))
# 	(if (> (outcome :highest) (best :y))
# 	  (set best {:y (outcome :highest) :vx vx :vy vy})))
#       (if (and (= :past-x (outcome :result))
# 	       (> (outcome :y) (target :ymax)))
# 	(set vy-looping? false)
# 	(++ vy))))
#   best)

#(def example-best (search example-target))
#(printf "example highest y is %j at vx=%j vy=%j"
#	(example-best :y) (example-best :vx) (example-best :vy))
# Taking too long. Maybe I'm overthinking this.

(defn search
  "loop over vx & vy - simpler"
  # This one just does an order-of-magnitude guesstimate
  # of the range of possible vx and vy ... which turns out
  # to be OK and fast enough.
  [target]
  (var best {:y math/-inf})
  (var count-solutions 0)
  (def vx-start 0)                         # x from not moving
  (def vx-end (inc (target :xmax)))        #   to getting there in 1 jump
  (def vy-start (target :ymin))            # y from getting there in 1 jump
  (def vy-end (math/abs (target :ymin)))   #   to the opposite upward.
  (loop [vx :range-to [vx-start vx-end]
	 vy :range-to [vy-start vy-end]]
    (def outcome (try vx vy target))
    (if (= :hit (outcome :result))
      (do
	(++ count-solutions)
	(if (> (outcome :highest) (best :y))
	  (set best {:y (outcome :highest) :vx vx :vy vy})))))
  [count-solutions best])

(def [example-count example-best] (search example-target))
(printf "example highest y is %j at vx=%j vy=%j"
	(example-best :y) (example-best :vx) (example-best :vy))

(def [day17-count day17-best] (search day17-target))
(printf "Day 17 Part 1 is %j" (day17-best :y))

(printf "number of example solutions is %j" example-count)
(printf "Day 17 Part 2 is %j" day17-count)






