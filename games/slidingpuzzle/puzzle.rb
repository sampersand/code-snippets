N = 4
$program = (1...N**2).map { |x| "%02d" % x } + %w[--]
$orig = $program.dup

def disp
  system "cls"
  puts $program.each_slice(N).map { _1.join(" ") }
end

def move(direction)
  idx = $program.index('--')  # Locate the empty space

  case direction
  when :up
    if idx >= N
      $program[idx], $program[idx - N] = $program[idx - N], $program[idx]
    end
  when :down
    if idx < N * (N - 1)
      $program[idx], $program[idx + N] = $program[idx + N], $program[idx]
    end
  when :left
    if idx % N != 0
      $program[idx], $program[idx - 1] = $program[idx - 1], $program[idx]
    end
  when :right
    if (idx + 1) % N != 0
      $program[idx], $program[idx + 1] = $program[idx + 1], $program[idx]
    end
  else
    raise "Invalid move: #{direction}"
  end
end

# Shufflethe board
1000.times { move %i[up down left right].sample }

require 'io/console'

def $stdin.getchar
  getch intr: true
rescue Interrupt
  exit
end

amnt = 0
until $orig == $program
  disp
  (first = $stdin.getchar) == 'q' and exit
  next unless first == "\e"
  next unless $stdin.getchar == '['

  case $stdin.getchar
  when ?B then move :down
  when ?A then move :up
  when ?D then move :left
  when ?C then move :right
  end

  amnt += 1
end

puts "Correct! It took you #{amnt} tries!"
