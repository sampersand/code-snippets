#!zsh

set -e

set -A words -- `cat ${DICTIONARY-/usr/share/dict/words} | grep '.\{5,\}'`
let "rand=`head -c4 /dev/urandom | od -DAn`"
set -A secret ${(Ls::)words[rand % $#words + 1]}

while (( 1 )) {
	## Print the hangman
	set -sA bad ${guesses:|secret}
	set o \| / \\ / \\ x x
	if ! shift -p `expr $# - $#bad` 2>/dev/null; then
		print >&2 oops, you didn\'t guess it! the word was ${(j::)secret}!
		exit 1
	fi
	print '\ec\e[3J' ; cat <<-EOS ; print
	 .---.
	 |   $1
	 |  ${3- }${2- }${4- }     $bad[1,4]
	 |  ${5- } ${6- }     $bad[5,-1]
	-+--${7--}-${8--}---
	${(*)secret//[! $guesses]/_}
	EOS

	## Read the word in
	while
		typeset -l char
		read -rsk char
		[[ $char != [[:alpha:]] ]]
	do done
	if (( $guesses[(I)$char] )) {
		print already read
		sleep 0.5
		continue
	}
	guesses+=($char)

	## If the guess is correct, then print and exit
	(( ${#secret:|guesses} )) || {
		print You win! the word was: ${(j::)secret}, and you had ${#secret:|guesses} mistakes
		exit 0
	}
}
