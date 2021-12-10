Advent of Code 2021

Jim Mahoney | cs.bennington.college | Dec 2021 | MIT License |
https://github.com/BenningtonComputing/advent-of-code/tree/master/2021/jim

I'm first going to start out with the Janet programming language
(janet-lang.org) - new to me but looks interesting. I've installed it
with homebrew, on macOS 11.6.1, along with its jpm package manager
(see *bootstrap* below).

 $ brew info janet
 janet: stable 1.18.1 (bottled), HEAD
 Dynamic language and bytecode vm
 https://janet-lang.org
 /usr/local/Cellar/janet/1.18.1 (145 files, 2.7MB) *
 From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/janet.rb

See :
 * https://adventofcode.com/2021         <======= advent of code !!
 * https://github.com/janet-lang
 * https://janet-lang.org/docs/index.html
 * https://janet-lang.org/docs/jpm.html (*bootstrap*)
 * http://www.unexpected-vortices.com/janet/notes-and-examples/index.html
 * https://github.com/MikeBeller/janet-cookbook

And I'll be using emacs and its janet tricks :
 * visiting *.janet uses janet-mode (paren bouncing & highlighting)
 * "M-x ijanet" launches interactive Ijanet repl window

Janet code examples :

  $ janet
  repl> (import* "./utils" :prefix "")    # to import these functions
  repl> (foo 3 4)
  7

  repl> (var values (file->ints "ints.txt"))
  @[1 2 3 4 5 6 7 8]
  repl> (seq [v :in values] (* 2 v))
  @[2 4 6 8 10 12 14 16]

  repl> (scan-number "123")
  123

  repl> (print [1 2 3])
  <tuple 0x...>

  repl> (pp [1 2 3])   # also (printf "%j" [1 2 3])   # %j ... janet?
  (1 2 3)

  repl> (string 123)
  "123"

And checkout these builtins :
  loop, seq, generate, accumulate, reduce, map, filter, ...

