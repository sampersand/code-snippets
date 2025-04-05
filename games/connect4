#!/bin/csh -f
set grid = `seq -w 1 25 | sed 's/.*/_/'`

set player = o
while ( 1 )
	tput reset
	echo $grid '' | fold -w10 | sed 's/.*/| &|/'
	echo +-1-2-3-4-5-+
top:
	if ( $player == 'x' ) then
		@ idx = (`random` % 5) + 1
	else
		set idx = $<
		switch ( "$idx" )
		case q:
			echo goodbye!
			exit
		case "":
		case *[^0-9]*:
			continue
		endsw
	endif

	set row = 4
	while ( $row >= 0 )
		@ x = $idx + ( 5 * $row )
	
		if ( $grid[$x] == '_' ) then
			set grid[$x] = $player
			break
		endif
		@ row --
	end
	
	if ( $row < 0 ) goto top

	if ( $player == x) then
		set player = o
	else
		set player = x
	endif
end
