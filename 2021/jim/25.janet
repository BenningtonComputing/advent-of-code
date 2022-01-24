``--- 25.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/25

      $ time janet 25.janet 
      Shape of example1-grid is (7 7)
      Shape of day25-grid is (137 139) i.e. 19043 grid cells
      Frequencies in day25-grid are @{118 4732 46 9652 62 4659}
      where empty=46 east=62 south=118
      example1 initial
      ...>...
      .......
      ......>
      v.....>
      ......>
      .......
      ..vvv..
      example1 after 1 move
      ..vv>..
      .......
      >......
      v.....>
      >......
      .......
      ....v..
      example1 after 4 moves
      >......
      ..v....
      ..>.v..
      .>.v...
      ...>...
      .......
      v......
      example0 initial is
      v...>>.vv>
      .vv>>.vv..
      >>.>v>...v
      >>v>>.>.v.
      v>v.vv.v..
      >.>>..v...
      .vv..>.>v.
      v.v..>>v.v
      ....v..v.>
      example0 final after 58 steps is
      ..>>v>vv..
      ..v.>>vv..
      ..>>v>>vv.
      ..>>>>>vv.
      v......>vv
      v>v....>>v
      vvv.....>>
      >vv......>
      .>v.vv.v..
      Day 25 Part 1 is 557

      real  0m11.925s
      user  0m11.680s
      sys   0m0.243s

This one was straightforward.

-------------------------------------------------------``
(use ./utils spork)

(def east (chr ">"))
(def south (chr "v"))
(def empty (chr "."))

(defn text->grid25 [text]
  (map string/bytes
       (filter (fn [x] (> (length x) 0))
               (map string/trim
                    (string/split "\n" text)))))
(defn print-grid25 [grid] (each line grid (print (string/from-bytes ;line))))

(def example1-grid (text->grid25 ``
  ...>...
  .......
  ......>
  v.....>
  ......>
  .......
  ..vvv.. ``))
(printf "Shape of example1-grid is %j" (shape example1-grid))

(def day25-grid (text->grid25 (slurp-input 25)))
(printf "Shape of day25-grid is %j i.e. %j grid cells"
        (shape day25-grid) (product (shape day25-grid)))
(printf "Frequencies in day25-grid are %j" (frequencies (flatten day25-grid)))
(printf "where empty=%j east=%j south=%j" empty east south)

(defn move-east [grid]
  (def [rows cols] (shape grid))
  (def result (grid-fill [rows cols] empty))
  (for row 0 rows
    (for col 0 cols
      (let [east-col (mod (inc col) cols)
            cell (.get grid [row col])
            east-cell (.get grid [row east-col])]
        (case cell
          east  (if (= empty east-cell)
                  (.put result [row east-col] east)
                  (.put result [row col] east))
          south (.put result [row col] south)))))
  result)

(defn move-east [grid]
  (var changed false)
  (def [rows cols] (shape grid))
  (def result (grid-fill [rows cols] empty))
  (for row 0 rows
    (for col 0 cols
      (let [east-col (mod (inc col) cols)
            cell (.get grid [row col])
            east-cell (.get grid [row east-col])]
        #(printf "row=%j col=%j east-col=%j cell=%j east-cell=%j"
        #        row col east-col cell east-cell)
        (case cell
          east  (if (= empty east-cell)
                  (do
                    (.put result [row east-col] east)
                    (set changed true))
                  (.put result [row col] east))
          south (.put result [row col] south)))))
  [result changed])

(defn move-south [grid]
  (var changed false)
  (def [rows cols] (shape grid))
  (def result (grid-fill [rows cols] empty))
  (for row 0 rows
    (for col 0 cols
      (let [south-row (mod (inc row) rows)
            cell (.get grid [row col])
            south-cell (.get grid [south-row col])]
        (case cell
          east (.put result [row col] east)
          south  (if (= empty south-cell)
                   (do
                     (.put result [south-row col] south)
                     (set changed true))
                   (.put result [row col] south))))))
  [result changed])

(defn move [grid]
  (def [grid1 change1] (move-east grid))
  (def [grid2 change2] (move-south grid1))
  [grid2 (or change1 change2)])

(defn move-n [grid n]
  (var result grid)
  (var changed false)
  (repeat n
          (def [new-grid _changed] (move result))
          (set result new-grid)
          (set changed _changed))
  
  [result changed])

(defn move-until [grid]
  (var result grid)
  (var changing true)
  (var steps 0)
  (while changing
    (def [new-grid changed] (move result))
    (++ steps)
    (set changing changed)
    (set result new-grid))
  [result steps])

(printf "example1 initial")
(print-grid25 example1-grid)

(def [ex1 ch1] (move example1-grid))
(printf "example1 after 1 move")
(print-grid25 ex1)

(def [ex1-4 ch1-4] (move-n example1-grid 4))
(printf "example1 after 4 moves")
(print-grid25 ex1-4)

(def example0-grid (text->grid25 ``
v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.> ``))

(printf "example0 initial is")
(print-grid25 example0-grid)
(def [example0-final example0-steps] (move-until example0-grid))
(printf "example0 final after %j steps is" example0-steps)
(print-grid25 example0-final)

(def [day25-stopped day25-steps] (move-until day25-grid))
(printf "Day 25 Part 1 is %j" day25-steps)


      
