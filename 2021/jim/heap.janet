``--- heap.janet ----------------

min heap storing [key value] pairs

This is a translation of the python code at
cs.bennington.college/courses/spring2021/
algorithms/notes/heap.attachments/heap_final.py into janet, with the
modification that I'm storing not just values, but [key value] pairs,
though the keys are irrelevant to the min-heap structure - it's the
[key value] pair with the lowest value which will be popped.

The binary heap is stored as an array :
@[ [key0 value0] [key1 value1] [key2 value2] ...]

   -- api --
   (heap/new)                create an empty heap (which is an array)
   (heap/push h [key val])   add data to the heap h
   (heap/pop h)              return and remove [key smallest-value] pair
   (heap/peek h)             return [key smallest-value] pair; h unmodified
   (heap/empty? h)           true if no items
   (length h)                number of items

   usage from another file in this folder:
   > import heap
   > (def h (heap/new))    # h is now just @[], an empty heap.
   > (heap/push h [:4 4])  # push some [key value] pairs into the heap.
   > (heap/push h [:1 1])
   > (heap/push h [:3 3])
   > (heap/push h [:2 2])
   > (pp (heap/pop h))     # pop removes the [key smallest-value] pair.
   (:1 1)
   > (pp (heap/pop h))     # and the next
   (:2 2)
   > (pp (heap/peek h))    # peak shows the next, without modifying h
   (:3 3)
   > (pp h)                # here's what's still left in the heap.
   @((:3 3) (:4 4))

   -- aside: janet's array api --
   (array item0 item1 ...) # create new array; same as @[item0 item1 ...]
   (array/remove array 0)  # remove from left of array
   (array/insert array 0 item)  # insert at left of array
   (array/push array item) # remove from right of array
   (array/pop array) # add to right end of array
   (array/peek array) # look at right of array, 
   (length array) # return length of array
   (get array i)  # return i'th item ; same as (array i)
   (put array i item) # put item into i'th slot ; same as (set (array i) item)

``

(defn parent "index of parent of node i" [i] (math/floor (/ (- i 1) 2)))
(defn left "index of left child of node i" [i] (inc (* 2 i)))
(defn right "index of right child of node i" [i] (+ 2 (* 2 i)))
(defn new "return new empty heap" [] (array))
(defn swap "swap [key value] pairs at indices i and j" [heap i j]
  (def tmp (get heap i))
  (put heap i (get heap j))
  (put heap j tmp))
(defn value "get value of item i" [heap i] (get-in heap [i 1]))
(defn has? [heap i] "is index i in heap?" (and (<= 0 i) (< i (length heap))))
(defn empty? [heap] (zero? (length heap)))
(defn last [heap] "index of last element" (- (length heap) 1))
(defn smallest-child "return index of smaller of children or nil" [heap i]
  (def _value (value heap i))
  (def _right (right i))
  (def _left (left i))
  (def _right-value (if (has? heap _right) (value heap _right) math/inf))
  (def _left-value (if (has? heap _left) (value heap _left) math/inf))
  (if (and (<= _value _right-value) (<= _value _left-value))
    nil
    (if (and (< _left-value _value) (< _left-value _right-value))
      _left
      _right)))
(defn bubble-up "percolate node upwards until its in the right place" [heap i]
  (def parent-i (parent i))
  (if (> i 0)
    (if (< (value heap i) (value heap parent-i))
      (do (swap heap i parent-i)
	  (bubble-up heap parent-i)))))
(defn bubble-down "percolate node down until its in the right place" [heap i]
  (def destination (smallest-child heap i))
  (if destination
    (do (swap heap i destination)
	(bubble-down heap destination))))
(defn push "push [key value] onto the min meap" [heap [key val]]
  (array/push heap [key val])
  (bubble-up heap (last heap)))
(defn peek "return [key smallest-value] but don't modify heap" [heap]
  (get heap 0))
(defn pop "remove and return [key smallest-value]" [heap]
  (if (empty? heap)
    nil
    (do
      (def result (get heap 0))
      (if (= 1 (length heap))
	(array/remove heap 0)
	(do
	  (put heap 0 (array/pop heap))
	  (bubble-down heap 0)))
      result)))

# -- tests --

# create an empty heap
(def h (new))

# pick some values to test
(def values [5 14 9 33 21 27 17 19 18])

# push [key val] pairs in the form [:5 5] into the heap.
(map (fn [x] (push h [(keyword x) x])) values)

# pop & collect each pair from the heap until its empty.
# Since each pop is the lowest, this gives the pairs in sorted order.
(def heapsort-key-vals (seq [i :iterate (pop h)] i))

# here's another way to get that sorted order of [key val] :
# sort the values, then turn into [key val].
(def sort-key-vals (seq [val :in (sorted values)] [(keyword val) val]))

# These two should be the same.
(assert (deep= heapsort-key-vals sort-key-vals))
	 
