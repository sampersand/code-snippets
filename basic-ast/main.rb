require_relative 'ast'
require_relative 'env'
require_relative 'parser'


def run_program(input)
  env = Environment.new
  parser = Parser.new input

  while (d = Declaration.parse parser)
    d.declare env
  end

  env.get_var('main').call(env)
end

run_program <<EOS
global max

function what_to_print(num) {
  if (num % 15) == 0 { return "FizzBuzz"; }
  if (num %  3) == 0 { return "Fizz"; }
  if (num %  5) == 0 { return "Buzz"; }
  else { return "" + num; }
}

function do_fizzbuzz() {
  array = [];

  while length(array) < max {
    array[length(array)] = what_to_print(length(array) + 1);
  }

  return array;
}

function print_fizzbuzz() {
  fb = do_fizzbuzz();
  i = 0;
  while i < length(fb) {
    print(fb[i]);
    i = i + 1;
  }
}

function main() {
  max = 100;
  print_fizzbuzz();
}
EOS
 
 
