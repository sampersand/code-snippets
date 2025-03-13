#!/bin/csh

alias space "sed 's/./& /g'"
alias chars 'wc -c'
if ( ! $?DICTIONARY ) then
	set DICTIONARY = /usr/share/dict/words
endif
echo $DICTIONARY
# test $DICTIONARY || DICTIONARY=/usr/share/dict/words
# set secret = `cat $DICTIONARY | grep '.\{5,\}' | sort -R | head -1 | tr A-Z a-z`
