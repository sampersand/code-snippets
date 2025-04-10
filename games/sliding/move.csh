#!/bin/csh -f

# The direction is the first argument
set dir = $1
shift

# Find the index of the blank space
@ idx = 1
while ( $argv[$idx] !~ *_ )
  @ idx++
end

switch ($dir)
case A: # A is up
  if ( $idx > $N ) @ other = $idx - $N
  breaksw
case B: # B is down
  if ( $idx <= $N * ($N - 1) ) @ other = $idx + $N
  breaksw
case C: # C is right
  if ( $idx % $N ) @ other = $idx + 1
  breaksw
case D: # D is left
  if ( ($idx - 1) % $N ) @ other = $idx - 1
  breaksw
default:
	echo invalid direction: $dir >/dev/stderr
  exit 1
endsw

# If a direction was found, then flip things
if ( $?other ) then
  set tmp          = $argv[$other]
  set argv[$other] = $argv[$idx]
  set argv[$idx]   = $tmp
endif

# Print out the grid regardless of what's been moved.
echo $argv

# Exit nonzero if we actually set something
exit ! $?other
