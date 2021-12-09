`` matrix.janet

Some linear algebra tools for working with nested tuples and arrays
with rectangular shapes, which can be treated as linear algebra
vectors, matrices, and tensors.

Examples include

    [1 0 3]                   # a vector with shape [3]

    @[3 1.5]                  # a mutable vector with shape [2]

    [[1 0] [0 1] [3 2]]       # a matrix with shape [3 2]

    @[@[@[1 2 3] @[4 5 6]]    
      @[@[0 1 0] @[4 5 6]]]   # a mutable tensor with shape [2 2 3]


 Operations
 (return tuples or arrays, same shape and type as the original)

    (.+ m1 m2)                 element-by-element addition
    (.- m1 m2)                 element-by-element subtraction
    (.* m1 m2)                 element-by-element multiplication
    (scale factor matrix)      scalar multiplication

 Access

    (.get m [row col ...])            slice notation? (maybe [elements] (range min max) :* )
    (.put m [row col ...] value)

 Functions

    (.map f m)                 apply f to each element; return same shape

    (shape m)                   [dim1 dim2 ...] e.g. [rows columns ...]
    (outer m1 m2)               outer product with shape [ ;(shape m1) ;(shape m2)]
    (dot m1 m2)                 inner dot product (i.e. matrix multiplication)
    (reshape m shape)

    (determinant m)             matrix determinant
    (transpose m)
    (invert m)                  multiplicative inverse

Jim Mahoney |  cs.bennington.college | MIT License | Dec 2021
``
