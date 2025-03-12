#!zsh

set -e

alias -g or='||'
set -A words -- `cat ${DICTIONARY-/usr/share/dict/words} | grep '.\{5,\}'`
let "rand=`head -c4 /dev/urandom | od -DAn`"
set -A secret1 ${(Ls::)words[rand % $#words + 1]}
typeset -l secret=${(j::)secret1}
typeset -U guesses2=()

function prhm {
	set -sA bad ${guesses2:|secret1}
	set o \| / \\ / \\ x x
	shift -p `expr $# - $#bad` 2>/dev/null || return
	# set +A argv $* ' ' " " ' ' " " ' ' " "

	print '\ec\e[3J' $secret ; cat <<-EOS ; print
	 .---.
	 |   $1
	 |  ${3- }${2- }${4- }     $bad[1,4]
	 |  ${5- } ${6- }     $bad[5,-1]
	-+--${7--}-${8--}---
	`echo $secret | sed "s/[^${guesses2:-x}]/_/g; s/./& /g"
	EOS
}

while (( 1 )) {
	prhm

	while
		read -rsk char
		[[ $char != [[:print:]] ]]
	do done

	integer old=$#guesses2
	guesses2+=($char)
	if (( $#guesses2 == $old )) {
		print already read
		sleep 0.5
		continue
	}

	(( ${#secret1:|guesses2} )) or break
}

print You win! the word was: ${(j::)secret1}, and you had ${#secret1:|guesses2} mistakes
# print You win! the word was: ${(j::)secret1}, and you had ${#guesses2:|secret1} mistakes
