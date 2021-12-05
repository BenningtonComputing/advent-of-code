"--- day1-2020.janet  -------------------------------------
 Warming up with the first puzzle from last year.
   $ janet day1-2020.janet
   2020 Day 1 Part 1 : (a,b)=(321,1699) ; product is 545379. 
-----------------------------------------------------------"
(import* "../utils" :prefix "")       

(def numbers "numbers from day1 2020, one per line"
  (map parse                                   # string -> integer
       (filter (fn [x] (> (length x) 0))       # ignore ""
	       (string/split "\n" (slurp "./input-day1-2020.txt")))))

(defn find-total-pair
  " Return (a,b) where both are in list of values, and they sum to total "
  [total values]
  (filter (fn [ [a b] ] (= (+ a b) total))
	  (array->pairs values)))

# (pp (find-total-pair 2020 numbers))
# @[(321 1699) (1699 321)]

(def (a b) (first (find-total-pair 2020 numbers)))
(printf "2020 Day 1 Part 1 : (a,b)=(%j,%j) ; product is %j." a b (* a b))






