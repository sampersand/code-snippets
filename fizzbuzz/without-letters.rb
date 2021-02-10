# Fizzbuzz without letters, `_`, or quotes
$/=%()<<70<<105<<122<<122 # $/ = Fizz
$\=%()<<66<<117<<122<<122 # $\ = Buzz
(1..100).%(1){
	$. += 1
	$. % 3 == 0 && $> << $/ # divisible by 3, print Fizz
	$. % 5 == 0 && $> << $\ # divisible by 5, print Buzz
	($.%3)*($.%5) != 0 && $> << $. # divisible by neither, print the number
	$> << (%()<<10) # print out a newline
}

