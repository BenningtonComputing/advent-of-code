``--- 5.janet ---------------------------------------
 https://adventofcode.com/2021/day/5

    $janet 5.janet 

-------------------------------------------------------``
(import ./utils :prefix "")       
(def day5-raw (slurp-input 5))
(def day5-lines (text->lines day5-raw))

(printf "The input for day5 starts with %j." (array/slice day5-lines 0 3))
(printf "Number of lines is %j." (length day5-lines))
(printf "Length of first line is %j." (length (day5-lines 0)))
(printf "----------------------------")
