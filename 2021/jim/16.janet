``--- 16.janet ---------------------------------------
  puzzle : https://adventofcode.com/2021/day/16

      $ time janet 16.janet 
      example "8A004A801A8002F478" version-sum is 16
      example "620080001611562C8802118E34" version-sum is 12
      example "C0015000016115A2E0802F182340" version-sum is 23
      example "A0016C880162017C3686B18A3D4780" version-sum is 31
      Day 16 Part 1 is 854
      example "C200B40A82" calculates to 3
      example "04005AC33890" calculates to 54
      example "CE00C43D881120" calculates to 9
      example "D8005AC2A8F0" calculates to 1
      example "F600BC2D8F" calculates to 0
      example "9C005AC2F8F0" calculates to 0
      example "9C0141080250320F1802104A08" calculates to 1
      Day 16 Part 2 is 186189840660
      real  0m0.014s
      user  0m0.009s
      sys   0m0.004s
-------------------------------------------------------``
(use ./utils)

(def day16-text (slurp-input 16))
#(print day16-text)

# I'll store the binary code as strings of 0's and 1's which I'll call "bits"
# Related janet functions :
#   (scan-number "A" 16)      => 10       # convert hex "A" to number base 16
#   (scan-number "1101" 2)    => 13       # convert string "1101" as base 2
#   (string/join ["aa" "bb"]) => "aabb"   # concatenate strings

(def charhex->4bits
  "conversion lookup table for hex byte to string of 4 0's and 1's."
  (zipcoll
   (string/bytes "0123456789ABCDEF")
   ["0000" "0001" "0010" "0011" "0100" "0101" "0110" "0111"
    "1000" "1001" "1010" "1011" "1100" "1101" "1110" "1111"]))

(defn hex->bits
  "convert hex text (e.g. '0F1') to bits object 
   (e.g. {:bits '000011110001' :index 0} )"
  [text]
  @{:bits (string/join (map charhex->4bits (string/bytes text)))
    :index 0})

(assert (= ((hex->bits "0F1") :bits) "000011110001"))

(def one (chr "1"))   # byte corresponding to ascii "1"
(def zero (chr "0"))  # byte corresponding to ascii "0"

# I'll store the bitstring to be parsed in an object
# { :bits "0111011001110010110000011"        # string of 1's and 0'2
#   :index 0                                 # current offset
# }

(defn get-value "get number from n bits; update index" [bits n]
  (def index (bits :index))
  (+= (bits :index) n)  
  (scan-number (slice-n (bits :bits) index n) 2))

(def field-length {:version        3
		   :typeID         3 
		   :lengthtypeID   1
		   :nbits          15
		   :npackets       11 })

(def field-spec   {:literal  4      # typeID
		   :nbits    0      # lengthtypeID
		   :npackets 1 })   # lengthtypeID

(defn BITS/value [bits field] (get-value bits (field-length field)))

(defn has? "Does the value x have this field property?"
  [x property]
  (= x (field-spec property)))

(defn bits-or-pckts [lengthtype]
  (if (has? lengthtype :nbits) :nbits :npackets))

(defn literal? [x] (has? x :literal))
(defn count-bits? [x] (has? x :nbits))
(defn count-packets? [x] (has? x :npackets))

(defn BITS/literal "extract and return a numeric value" [bits]
  (def literal @"")             # buffer to accumulate the literal
  (var index (bits :index))     # pull out index
  (def bts (bits :bits))        # pull out bitstring
  (loop [[last0 group] :iterate [(bts index) (slice-n bts (inc index) 4)]]
    (buffer/push literal group)
    (+= index 5)
    (if (= last0 zero) (break)))
  (put bits :index index)       # update index for characters we've passed
  (scan-number literal 2))      # return from accumulated 0's and 1's 

(def example1-hex "D2FE28")
(def example1-bits (hex->bits example1-hex))
#(printf "example1 hex %j => bitstring %j" example1-hex example1-bits)

(defn BITS/packet "extract and return a packet object" [bits]
  (def packet @{ :subpackets @[] })
  (def index-start (bits :index))
  (put packet :version (BITS/value bits :version))
  (put packet :typeID (BITS/value bits :typeID))
  (if (literal? (packet :typeID))
    (put packet :literal (BITS/literal bits))
    (do (def length-type (BITS/value bits :lengthtypeID))
	(def length-needed (BITS/value bits (bits-or-pckts length-type)))
	(var subpacket-bits 0)
	(while (or 
		 (and (count-packets? length-type)
		      (< (length (packet :subpackets)) length-needed))
		 (and (count-bits? length-type)
		      (< subpacket-bits length-needed)))
	  (def subpkt (BITS/packet bits))               # recursive sub packet
	  (+= subpacket-bits (subpkt :bitlength))       # update total sub bits
	  (array/push (packet :subpackets) subpkt))))   # update array of kits
  (put packet :bitlength (- (bits :index) index-start))
  packet)

#(printf "example1 packet %j" (BITS/packet example1-bits))

(def example2-hex "38006F45291200")
(def example2-bits (hex->bits example2-hex))
#(printf "example2 hex %j bits %j" example2-hex example2-bits)
#(printf "example2 packet %j" (BITS/packet example2-bits))

(def example3-hex "EE00D40C823060")
(def example3-bits (hex->bits example3-hex))
#(printf "example3 hex %j bits %j" example3-hex example3-bits)
#(printf "example3 packet %j" (BITS/packet example3-bits))

(defn version-sum [packet]
  (+ (packet :version)
     ;(seq [p :in (packet :subpackets)]
	   (version-sum p))))

(defn example-version-sum [hex]
  (printf "example %j version-sum is %j"
	  hex (version-sum (BITS/packet (hex->bits hex)))))

(each hex
    ["8A004A801A8002F478"
     "620080001611562C8802118E34"
     "C0015000016115A2E0802F182340"
     "A0016C880162017C3686B18A3D4780"]
     (example-version-sum hex))

(def day16-text (string/trim (slurp-input 16)))
(def day16-packet (BITS/packet (hex->bits day16-text)))
(printf "Day 16 Part 1 is %j" (version-sum day16-packet))

(def operation
  {  4  :literal
     0  :sum
     1  :product
     2  :minimum
     3  :maximum
     5  :greater
     6  :lesser
     7  :equal   })

(defn is> [args] (if (> ;args) 1 0))
(defn is< [args] (if (< ;args) 1 0))
(defn is= [args] (if (= ;args) 1 0))

(defn calculate [packet]
  (defn sub-calc [pckt] (map calculate (pckt :subpackets)))
  (case (operation (packet :typeID))
    :literal 	(packet :literal)
    :sum	(+    ;(sub-calc packet))
    :product    (*    ;(sub-calc packet))
    :minimum    (min  ;(sub-calc packet))
    :maximum    (max  ;(sub-calc packet))
    :lesser     (is<  (sub-calc packet))
    :greater    (is>  (sub-calc packet))
    :equal      (is=  (sub-calc packet))))

(defn example-calculate [hex]
  (printf "example %j calculates to %j"
	  hex (calculate (BITS/packet (hex->bits hex)))))

(each hex
    ["C200B40A82"
     "04005AC33890"
     "CE00C43D881120"
     "D8005AC2A8F0"
     "F600BC2D8F"
     "9C005AC2F8F0"
     "9C0141080250320F1802104A08"]
     (example-calculate hex))

(printf "Day 16 Part 2 is %j" (calculate day16-packet))
