#!/bin/csh -f

# Remove the cursor; When interrupted, restore it.
onintr reset_tty
tput civis

# Set the width of the slide puzzle.
if ( $#argv < 1 ) set argv = ( 4 )
setenv N $argv[1]                # Env var so `move` can access it.
set movepath = `dirname $0`/move # Path to the `move` script

# Aliases for later uses
@ foldwith = (2 + 1) * $N # Really is "max length + 1" F(or the spae)
alias disp 'tput clear; echo $grid | sed "s/\./ /g" | fold -w$foldwith'
alias rand 'head -c4 /dev/random | od -An -D'
alias move 'set grid = (`$movepath \!:1 $grid`)'
alias getc 'stty raw; set reply = (`dd bs=1 count=1 status=none`); stty -raw'

# Create the grid
@ maxlen = $N * $N - 1
set grid = (`seq -w 1 $maxlen | sed 's/^0/./'` __)
set answer = ( $grid )

# Shuffle the grid
@ iters = $N * $N * $N
set directions = (A B C D)
while ( $iters )
	@ diridx = `rand` % $#directions + 1
	move $directions[$diridx] || continue
	@ iters --
end

# Main loop: Read characters and slide the board around
@ slides = 0
set ctrlc = `printf %b \\003` # TODO
set esc   = `printf %b \\033`
while ( "$grid" != "$answer" )
	disp
	echo; echo Arrow keys to move. q to quit; echo $slides slide\(s\) so far

	# Support arrow keys (which are `ESC + [ + A/B/C/D`), along with `q` to quit,
	# and the "Ctrl+C" character for exiting
	getc
	switch ( $reply )
	case q:
	case ${ctrlc}:
		goto reset_tty # Exit if `q` or ctrl+c were given

	# If given any other sequence other than `ESC + [ + <A/B/C/D>`, then just
	# re-do the loop.
	case ${esc}:
		getc; if ( $reply != '[' ) continue
		getc; if ( $reply !~ [ABCD] ) continue
		move $reply
		if ( ! $status ) @ slides++
	endsw
end

# Print out the message when you win
disp
echo Congrats, you win! it took you: $slides slide\(s\)!
# FALLTHROUGH

# Restore cursor back to normal
reset_tty:
tput cnorm
