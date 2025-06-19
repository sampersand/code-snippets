#!/bin/csh -fe

alias split "sed 's/./& /g'"
alias echoa "echo \!:* | sed 's/ /\n/g'"
if ( ! $?HANGMAN_TEMPDIR ) then
    set HANGMAN_TEMPDIR = /tmp/hangman/$$
endif
mkdir -p "$HANGMAN_TEMPDIR"
cd "$HANGMAN_TEMPDIR"
# AT_EXIT: `rm -r $HANGMAN_TEMPDIR`

if ( ! $?DICTIONARY ) then
    set DICTIONARY = /usr/share/dict/words
endif

set secret = `cat $DICTIONARY:q | grep '.\{5,\}' | sort -R | head -1 | tr A-Z a-z | split`

## ...

set secret = ( e x p e r i e n t i a l l y )
set guesses = ( x y e r n q )
set secret = ( x a b y q )
set guesses = ( x y z )

# while ( 1 )

set shared = ( ` \
    echoa $secret | sort > tmp; \
    echoa $guesses | sort | comm -13 tmp -; \
`)

echo $shared
exit
#set hm = ()
echo $shared
    set -sA bad ${guesses:|secret}
    set o \| / \\ / \\ x x
    if ! shift -p `expr $# - $#bad` 2>/dev/null; then
        print >&2 oops, you didn\'t guess it! the word was ${(j::)secret}!
        exit 1
    fi
    tput clear; cat <<-EOS ; print
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
        print You win! the word was: ${(j::)secret}, and you had ${#guesses:|secret} mistakes
        exit 0
    }
}


#
# alias space "sed 's/./& /g'"
# alias chars 'wc -c'
# #
# if ( ! $?DICTIONARY ) then
#     set DICTIONARY = /usr/share/dict/words
# endif
#
# set secret = `cat $DICTIONARY | grep '.\{5,\}' | sort -R | head -1 | tr A-Z a-z`
# echo $secret
#
# set guesses = ( a b c )
# set bad = ( `echo $guesses | sed "s/[$secret]//g"` )
# echo $bad
# #
# # while :
# # do
# #     ## Print the hangman
# #     bad=`echo $guesses | sed 's/[$secret]//g'`
# #     nerr=`expr \`echo $bad | chars\` - 1`
# #     set -- # No idea why this needs to be here, but if i remove it we fail.
# #     set - `echo 'o|/\/\xx@' | { test $nerr -gt 0 && cut -c-$nerr; } | space`
# #     if test $# -ge 9
# #     then
# #         >&2 echo oops, you didnt guess it! The word was $secret!
# #         exit 2
# #     fi
# #     while test $# -lt 6; do set "$@" ' '; done
# #     while test $# -le 8; do set "$@" '-'; done
# #
# #     echo '\033c\033[3J'
# #     echo ' .---.'
# #     echo " |   $1"
# #     echo " |  $3$2$4     `echo $bad | cut -c-4 | space`"
# #     echo " |  $5 $6     ` echo $bad | cut -c5- | space # leading space needed`"
# #     echo "-+--$7-$8---"
# #     echo $secret | sed s/[^@$guesses]/_/g | space
# #
# #     ## Read the word in
# #     while
# #         read char || exit 9
# #         case $char in
# #             [$guesses]) continue 2 ;;
# #             [a-z]) false ;;
# #             *) : ;;
# #         esac
# #     do :; done
# #
# #     guesses=$guesses$char
# #
# #     ## If the guess is correct, then print and exit
# #     if test x = x`echo $secret | sed "s/[$guesses]//g"`
# #     then
# #         break
# #     fi
# # done
# #
# # # NOTE: No trailing `EOS` is intentional, dash accepts that lolol
# # cat <<EOS
# # You win!
# # The word was: $secret
# # You had `expr \`echo -n $guesses | sed s/[$secret]//g | chars\`` mistake(s)
