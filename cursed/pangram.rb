#!ruby -W0anF(?=) -rstringio

=begin prompt
Prompt: Create a program that can check to see if an input
(given any way you want) contains all the letters in the
alphabet, case-insensitive. Note that the input string will
only be ascii, but it may contain non-alphabetic letters.
Make it cursed.
=end of the prompt

END{p$====032}
BEGIN{$_=$0.tr *%w*A-Z a-z*;sub$&,%  while/[^[:alpha:]]/; $stdin=StringIO.new$_}

eval <<'''$==0''' if 2..2
alias$=$-_
def ($stdin=$F.sort).gets = shift

$=+=1if%r
#{[0D97+$=].pack ?C}
nonissue

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
- regex in conditions (`/[[:alpha:]]/`)

you can use the below before the `END` if you dont want to read data from `$0`
BEGIN{$0="the quick brown fox jumps over the lazy dog"}
