Advent of Code 2021

I'm first going to try out Janet (janet-lang.org),
which I've installed with homebrew. (And I also
installed the jpm package manager; see ~/system/history.txt.)

See 
 * https://janet-lang.org/docs/index.html
 * http://www.unexpected-vortices.com/janet/notes-and-examples/index.html
 * https://github.com/MikeBeller/janet-cookbook

In emacs :
 * visiting *.janet uses 
 * "M-x ijanet" launches interactive Ijanet repl window

Examples:

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

