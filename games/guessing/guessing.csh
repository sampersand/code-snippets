#!/bin/csh -f

if ( $#argv ) then
	@ max = $1
else
	echo what is max number\?
	@ max = $<
endif

@ secret  = (`random` % $max) + 1
@ guesses = 0

echo Guessing game! Pick a random \
	number from 1 to $max!

while ( 1 )
	set tmp = $<
	if ( "$tmp" =~ *[^0-9]* || "$tmp" == "") continue
	@ guess = $tmp
	@ guesses++

	if ($guess < $secret) then
		echo Too Low!
	else if ($guess > $secret) then
		echo Too High!
	else
		break
	endif
end

echo You win! It took you $guesses guesses! 

