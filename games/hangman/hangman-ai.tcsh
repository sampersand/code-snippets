#!/bin/tcsh

# Load a random word from /usr/share/dict/words
set word = `shuf -n 1 /usr/share/dict/words | tr -d -c 'A-Za-z'`

# Initialize game variables
set correct_guesses = ""
set incorrect_guesses = ""
set max_incorrect = 6
set incorrect_count = 0

# Function to display the word with underscores for unguessed letters
alias display_word 'set masked_word = ""; foreach c ( `echo $word | sed "s/./& /g"` ) \
    if ( "$correct_guesses" =~ *$c*) then @ masked_word = "$masked_word$c" else @ masked_word = "$masked_word_" endif end; echo $masked_word'

# Function to check if the player has guessed the word
alias check_winner 'if ( "$correct_guesses" == "$word" ) echo "Congratulations, you guessed the word!"'

# Main game loop
echo "Welcome to Hangman!"
echo "The word has `echo $word | wc -c` letters."

while ( $incorrect_count < $max_incorrect )
    # Display the current state of the word
    display_word
    echo "Incorrect guesses: $incorrect_guesses"
    echo "You have $((max_incorrect - incorrect_count)) attempts left."
    echo -n "Guess a letter: "
    set guess = $<

    # Check if input is a single letter
    if ( `echo $guess | wc -c` != 2 || ! $guess =~ [a-zA-Z] ) then
        echo "Please enter a single letter."
        continue
    endif

    # Convert guess to lowercase
    set guess = `echo $guess | tr 'A-Z' 'a-z'`

    # Check if the letter was already guessed
    if ( "$correct_guesses$incorrect_guesses" =~ *$guess* ) then
        echo "You already guessed $guess."
        continue
    endif

    # Check if the guess is in the word
    if ( "$word" =~ *$guess* ) then
        echo "$guess is correct!"
        set correct_guesses = "$correct_guesses$guess"
    else
        echo "$guess is incorrect!"
        set incorrect_guesses = "$incorrect_guesses$guess"
        @ incorrect_count++
    endif

    # Display the word and check for a win
    check_winner
end

if ( $incorrect_count >= $max_incorrect ) then
    echo "Sorry, you lost! The word was: $word"
endif
