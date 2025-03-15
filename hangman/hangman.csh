#!/bin/tcsh -f

alias space "sed 's/./& /g'"
alias chars 'wc -c'

if ( ! $?DICTIONARY ) set DICTIONARY = /usr/share/dict/words
set secret = ( `cat $DICTIONARY | grep '.\{5,\}' | sort -R | head -1 | tr A-Z a-z | sed "s/./& /g"` )

set secret = (p e r c e p t i v i t y)
set guesses = (e q v i)

echo $secret

# Initialize an empty array to store the intersection
set intersection = ()

# Loop through each element of secret
foreach item1 ($secret)
    # Check if the element exists in guesses
    if ( $item1 =~ $guesses ) then
    	echo $item1
        # Add the element to the intersection array
        set intersection = ($intersection $item1)
    endif
end

# Print the intersection array
echo "Intersection: $intersection"


# exit

# 	## Print the hangman
# 	bad=`echo $guesses | sed s/[$secret]//g`
# 	nerr=`expr \`echo $bad | chars\` - 1`

# echo $secret
