# Fizzbuzz, in Ruby!
# Run the program and it'll print out fizzbuzz from 1-N, defaulting to 100
# (You can change `N` by passing an additional argument on the command line)

# NOTE: all the `at_exit`s used to be `END`s, but as of ruby-3.5.0preview1, that's been
# deprecated :-(.

BEGIN{$* << 0144 unless $*[0D0]}
~/a/ and Fizz ? Buzz : $.
END{eval ?( + <<'__END__' ').tap{eval $-_}' rescue $-_=DATA.read }
$. += __LINE__ and $_ = %\#$.\\
__END__
BEGIN{defined?(__END__)[__LINE__]{<<~__END__} rescue at_exit{eval <<-'__END__'rescue
  =begin 🟥🐟
__END__
for $= in __LINE__..__END__ do eval DATA.tap(&:rewind).read end
class Integer def ==(r)=0===r%self end
__END__
at_exit{abort <<-"__END__"}}}
usage: #$0 MAX
__END__
END{$*&.[](0)&.to_i&.-@&.~@ => __END__}
$-w=$-q
__END__
BEGIN{print unless (not print <<~`__END__`.chop if 3..3) | (not print <<`__END__`.chop if /[05]$/)}
echo Fizz
__END__
echo Buzz
__END__
?\C-J.display
__END__
=end 🟥🐟
