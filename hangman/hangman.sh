#!/bin/dash

alias space="sed 's/./& /g'"
alias chars='wc -c'
test $DICTIONARY || DICTIONARY=/usr/share/dict/words
secret=`cat $DICTIONARY | grep '.\{5,\}' | sort -R | head -1 | tr A-Z a-z`

while :
do
	## Print the hangman
	bad=`echo $guesses | sed s/[$secret]//g`
	nerr=`expr \`echo $bad | chars\` - 1`
	set -- # No idea why this needs to be here, but if i remove it we fail.
	set - `echo 'o|/\/\xx@' | { test $nerr -gt 0 && cut -c-$nerr; } | space`
	if test $# -ge 9
	then
		>&2 echo oops, you didnt guess it! The word was $secret!
		exit 2
	fi
	while test $# -lt 6; do set "$@" ' '; done
	while test $# -le 8; do set "$@" '-'; done

	echo '\033c\033[3J'
	echo ' .---.'
	echo " |   $1"
	echo " |  $3$2$4     `echo $bad | cut -c-4 | space`"
	echo " |  $5 $6     ` echo $bad | cut -c5- | space # leading space needed`"
	echo "-+--$7-$8---"
	echo $secret | sed s/[^@$guesses]/_/g | space

	## Read the word in
	while
		read char || exit 9
		case $char in
			[$guesses]) continue 2 ;;
			[a-z]) false ;;
			*) : ;;
		esac
	do :; done

	guesses=$guesses$char

	## If the guess is correct, then print and exit
	if test x = x`echo $secret | sed "s/[$guesses]//g"`
	then
		break
	fi
done

cat <<EOS
You win!
The word was: $secret
You had `expr \`echo -n $guesses | sed s/[$secret]//g | chars\`` mistake(s)
