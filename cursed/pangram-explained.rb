#!ruby -W0naF(?=) -rstringio
BEGIN{$0="the quick brown fox jumps over the lazy dog" }

# We use a shebang so we can pass arguments to the ruby interpreter that otherwise would be given
# on the command line. All the options that're passed are:
# * `-W0` This disables all warnings, which in this program is caused by regexps in conditions.
# * `-n` Will call the entire program for every line in the input, storing the input line in `$_`.
# * `-a` Enables autosplit mode, which splits `$_` by the `-F`'s argument and stores it in `$F`
# * `-F` takes a regex, and splits `$_` by it. (The regex is `(?=)`, so we just split on each char).
# * `-rstringio` is the same as `require "stringio"`, and imports it

# In ruby, multiline comments are technically allowed via `=begin ... =end`, with the caveat that
# the `=begin` and `=end`s must be at the very beginning of a line. A lesser-known fact is that
# you're able to add arbitrary text after them, which is ignored by the parser.
=begin prompt
Prompt: Create a program that can check to see if an input
(given any way you want) contains all the letters in the
alphabet, case-insensitive. Note that the input string will
only be ascii, but it may contain non-alphabetic letters.
Make it cursed.
=end of the prompt

# This line is run only at the very end of the program. It prints out whether the global variable
# `$=` is equal to 26. `032` is octal for 26, and for integers, `===` is the same as `==`. This is
# where we determine whether the input as a pangram: Every time a unique letter is encountered, `$=`
# has one added to it. If, at the end, all 26 letters were encountered, then we know it's a pangram.
#
# One thing to note is that `BEGIN` and `END` blocks are only ever run once, even with `-n`.
END{p$====032}

# This code is run at the very beginning of the program, before anything else is.
BEGIN{
  # We accept our input in the variable `$0`---ie the program name. That is, to change the input,
  # you must change the program name (lol). We take the input and translate all upper case letters
  # to lowercase via `tr`, assigning the return value to `$_` (which will be used in the next line).
  # The `*%w*A-Z a-z*` syntax is using percent-literals. This is the same as `*['A-Z', 'a-z']`.
  $_=$0.tr *%w*A-Z a-z*

  # There's quite a bit to unpack here. This statement is simply removing all non-letters from the
  # input. That way, `$_` will only contain letters. This expression can be expanded out to:
  #   while $_ =~ /[[:alpha:]]/
  #     $_.sub! $&, ""
  #   end
  # Let's go over the expansions one at a time:
  # - `/[[:alpha:]]/` uses POSIX bracket expressions. This is equivalent to `[a-zA-Z]`.
  # - `while`s, if given a regex literal, will interpret their condition as matching against the
  #   `$_` variable. That is, `while /x/` is the same as `while $_ =~ /x/`. (`$_` was set in the
  #    previous line). `String#=~`'s return value is `nil` if the regex doesn't match, so this
  #    will only stop when the input doesn't match `/[[:alpha:]]/`---i.e., it is all ascii letters.
  # - `%  ` Is, once again, abusing the `%` literal syntax, taking advantage of the fact that _any_
  #   non-word character can be the delim. In this case, we use ` ` itself. Additionally, if no
  #   "type" is supplied with `w` literals, it's assumed to be a string. So `%  ` is actually the
  #   same as `%()`, which is an empty string.
  # - `$&` is a special variable that's set when matching against regexps. When a regex is matched,
  #   the entire matched string is set to the variable `$&`. In this case, it means the non-letter
  #   that's matched in the `while`'s condition is set to `$&`.
  # - `sub` is a function that's only defined if the `-n` or `-p` flags are supplied, and is the
  #   same as `$_.sub!`. In this case, it's `$_.sub!($&, "")`, which will replace the first instance
  #   of the non-letter with an empty string, thus removing it from `$_`.
  sub $&, %  while /[[:alpha:]]/

  # The `-n` flag actually pulls from `$stdin` after all `BEGIN`s are executed. So, by using the
  # `StringIO`, we can change the stdin to be the value of `$_`--that is, the stripped input string.
  $stdin = StringIO.new $_
}

# At this point, the `BEGIN` has finished executing. So now, `$_` will be the input, as it was
# read from the `StringIO` that was created. Since we specified `-a` and `-F` , the global variable
# `$F` will be set to `$_.split(/(?=)/)`, which is just each character of `$_`: In essence, it's a
# long-winded way of writing `$F = $_.chars`.

# This is probably my favourite line in the entire program. Expanded out, this is equivalent to
#   if $. == 2
#     eval (<<'') + '$= = 0' end
# Let's go through them one-by-one.
# - Ruby has HEREDOCs, which are a way to embed multiline strings. You've probably seen them started
#   with `<<EOS`, but ruby actually allows for _any_ arbitrary pattern to be used, as long as it is
#   surrounded with quotes. So `<<''` is actually a heredoc that's completed when an _empty line_ is
#   read, which is the line directly after `def`: That is, the two subsequent lines (the `alias` and
#   `def` ones) are actually part of a string literal.
# - Ruby, like C, allows you to put multiple string literals next to eachother, and will concatenate
#   them: `puts 'Hello' 'world'` is _identical_ to `puts 'Helloworld'`. And, HEREDOCs are actually
#   string literals. So the `<<'''$==0'''` is actually three separate string literals right next to
#   one another: The first is the heredoc, the second is `'$==0'`, and the last is an empty string,
#   which is just used to make it look nice. The `eval` call is thus `eval(<<'' + '$= = 0')`.
# - `$=` is a global variable in Ruby, but it has been defunct for decades now---assigning to it
#   gives warning and is ignored, and reading from it returns `false`. (It used to be used to toggle
#   case sensitivity on _all_ regexes: If it was set to `true`, all regexes implicitly had a `/i`
#   flag.) The string `'$==0'` is actually `$= = 0`, which is setting `0` to `$=`.  Normally, this
#   isn't allowed, but the `alias` allows for it (see the next line's comments for more).
# - `if 2...2` uses another weird thing in Ruby---flipflops. You can learn more by googling them,
#   but essentially flipflops (with the syntax `if lhs..rhs`) store a "memory" of their previous
#   values: once the `lhs` is true, the condition will always be true (regardless of whether `lhs`
#   becomes false in the meantime) until `rhs` becomes true, at which point the flipflop "resets"
#   and waits for the `lhs` to become true again. (There's two variants, `..` and `...`; the
#   difference being `...` will check `rhs` the first time `lhs` becomes true, whereas `..` will.)
#
#   In the spirit of weirdness, I used an almost entirely unknown feature of this unknown feature of
#   ruby---using integer literals in flipflops. If you use an integer literal instead of a normal
#   expression within a flipflop, it's the same as checking whether the current line number (`$.`)
#   equals that integer: So, the flipflop `if 2..2` is actually equivalent to `if $.==2 .. $.==2`.
#   Since I used the `..` variant, and the two sides are identical, it's equivalent to `if $.==2`.
#
#   "But why `2`," you ask, "didn't we only read a single line from stdin?" Well, yes. Sort of.
#   Technically, yes we only read a single line from stdin, and technically `$.` starts at 0, so you
#   would expect the condition to be `if 1..1`. And normally, you'd be right. But due to a weird
#   quirk of ruby's implementation of command-line-argument parsing, if you provide a shebang at the
#   top of a file, `$.` actually starts at 1 and _not_ 0. So in this case, `if 2..2` will only
#   evaluate true when this is the first line we've read from stdin.
#
# Overall, the _entire_ expression is:
#   if $. == 2 # ie if this is the first line we read from stdin
#      eval("alias$=$-2\ndef ($stdin=$F.sort).gets = shift\n$= = 0")
#   end
# Phew!
eval <<'''$==0''' if 2..2
# (Normally i'd put an empty line here for visual spacing, but I cannot as `<''` would interpret it
# as an end of input)
#
# Most people know `alias` in the context of methods: do `alias foo bar` and calling `foo` is the
# same as calling `bar`. But `alias` also has another purpose: Aliasing global variables. (In fact,
# quite a few builtin globals are aliased to one another: `$0/$PROGRAM_NAME`, `$>/$stdout`,
# `$-v/$VERBOSE`.)
#
# Why is this relevant? Because we're aliasing `$=` to be `$-_`. Normally, you cannot interact 
# all with `$=---its "setter" method just ignores the value and warns, and its "getter" method
# always returns `false`. However, if you alias `$=` to another global variable, you overwrite those
# getters and setters, thus allowing you to use `$=` just like any other global variable. I could
# have picked (normal) global variable for it, but I chose `$-_`:
#
# Asides from the perl-esque global variables (`$"`, `$:`, `$@`, etc.), Ruby also has global
# variables for command line arguments: `$-v` is set to true if the `-v` flag was given, `$-F` is
# set to the regex passed to `-F`, `$-0` is the input line separator (set via `-0`), etc. But Ruby's
# parser actually allows for _any_ global variable that matches `$-[a-zA-Z0-9_]` to be used. So, why
# not use `$-_` for fun?
alias$=$-_
#
# Here we are, once again, overwriting `$stdin`. You're allowed to overwrite `$stdin` mid-execution,
# even if `-F` was specified---the next line will simply read from the new stdin. There's on caveat:
# Anything assigned to `$stdin` needs to have a `gets` method defined on it, which will be called
# whenever a new line is read. (Technically, you only need it defined whenever you read a new line,
# not when assigned, which is why what we do is valid).
#
# So we do exactly that, defining `gets` on the `$stdin` array as simply removing the first element.
# As a bonus, `shift` returns `nil` when there's nothing left in the array, which also indicates
# that there's nothing left to read for `$stdin`. Note that we sort `$F`, because our logic expects
# the input to be sorted.
def ($stdin=$F.sort).gets = shift
# (Remember that `$= = 0` is run after the `def`, as it's part of the `eval` string literal)
# ... and _now_ the string literal ends, as the next line is an empty line.

# And now we get to the last part, the actual checking to see if the input is a pangram. The
# following three lines can be reduced down to:
#   if $_ =~ /#{(97+$=).chr}/
#      $= += 1
#   end
# Let's break it down:
# - `1if` The ruby parser technically allows integer literals immediately before keywords for some
#   reason. We abuse that here to make the code look funkier.
# - `%r...nonissue` Once again, we take advantage of `%` literals. Like before, any delim can be
#   used, so this time we use newlines: The first newline (immediately after the `%r` is the start
#   of the regex literal, and the second one (after the interpolation) is the end of it. And, since
#   regex flags are defined immediately after the delim (and repeated flags are ignored), the
#   condition can be simplified to `/#{...}/noisue`.
#
#   Most of those flags are irrelevant and are simply supplied to make an actual English word. The
#   interesting one is `/o`, which indicates that the regex should only do interpolation once. The
#   odd part is that, if a regex literal is used as condition for `if`, the `/o` flag is ignored.
# - `if /.../` - Similar to the `while /.../` from earlier, using a regex literal within an `if`'s
#   condition is the same as `if $_ =~ /.../` (barring the `/o` idiosyncrasy mentioned in the
#   previous paragraph.) Thus, `$=` will be incremented by 1 if the regex matches the current line.
# - `0D97` In addition to `0x`, `0o`, and `0b` numerical literals, Ruby also has `0d`, which is
#   base 10 (and is thus entirely irrelevant.) So `0D97` is the same as `97`.
# - `?C` In the olden days, there used to be a difference between strings and chars---chars literals
#   were denoted via `?` followed by a character. When they were unified in Ruby 1.8, the `?` syntax
#   stayed around, but simply meant a string of length one. So `?C` is the same as `'C'`.
# - `[97+$=].pack 'C'` This uses `Array#pack` to convert `97+$=` into a string based on the format
#   string (`'C'`). Just a `'C'` simply takes the first element in the array and converts it to its
#   character value. In essence, this is an overengineered version of `(97+$=).chr`.
# So, `$=` is incremented by one only if the current line includes the character denoted by `97+$=`.
# As `97.chr` is `'a'`, this adds 1 to `$=` if the current line contains the next letter in the
# alphabet.
$=+=1if%r
#{[0D97+$=].pack ?C}
nonissue

# Lastly, we get to the `__END__`. In Ruby, everything after an `\n__END__\n` is ignored and
# considered a comment. (There are other uses for it---`DATA`---but I don't use that here.)
__END__
hopefully every single line in here should have something odd about it.
let's take the first two (non-shebang/comment) lines alone:
- we're using `BEGIN`/`END`
- `$====` is used and is valid syntax
- octal literals
- the input is the program name
- setting `$_` in a `BEGIN`
- `%w` literals with non-standard delims: `*%w*...*`
- using `Kernel#sub`
- using `%<space><space>` as an empty string
- regex in conditions (`/\W|\d/`)

You can use the below before the `END` if you dont want to read data from `$0`
# BEGIN{$0="the quick brown fox jumps over the lazy dog"}
