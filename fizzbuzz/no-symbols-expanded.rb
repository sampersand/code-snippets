# Fizzbuzz in Ruby! This program uses only uppercase, lowercase, and `_` characters.

# The only way to call member functions without using symbols in ruby is to go through the builtin
# "conversion" functions, such as `Integer()`, `Float()`, etc., which call the builtin methods such
# as `to_i`, `to_f`, etc.
#
# To get the numbers three and five, we add the methods `to_i` and `to_f` to `Array` (which assume
# `self` has length one) to append enough elements to get the desired length.
class Array
  def to_i
    push true
    push true
    length
  end

  def to_f
    push true
    push true
    push true
    push true
    Float length
  end
end
def three
  Integer Array true end
def five
  Integer Float Array true end

# When you `puts` a symbol, it prints it just like it would print a `String`.
# Since `__method__` returns the name of the method its defined in, we can emulate
# the code `puts "Fizz"` by running `puts Fizz nil`. The argument is required, as
# otherwise ruby looks for a constant with the name `Fizz`.
def Fizz _
  __method__ end
def Buzz _
  __method__ end
def FizzBuzz _
  __method__ end

class Integer
  # This is so we can use integers in `for` loops.
  alias each times

  # `object_id` returns an integer, so iterating over it will start at zero. We break
  # immediately, which means `z` is defined as zero, which is used in the next line.
  for z in object_id do break end

  # We define a function named "0". This may seem a bit weird, but it's how `modthree` and
  # `modfive` work.
  define_method String z do true end

  # Checks to see if `self` is divisible by three (or five). We do this by trying to call a method
  # on `self` whose name is `self % 3` (or `self % 5`). Normally, this would never be defined, but
  # since we just defined the function `"0"` the line before, we will call that function (which
  # returns true). The `rescue` is to catch every other value—which will throw a `NoMethodError`—and
  # returns `false`.
  def modthree
    send String modulo three rescue false end
  def modfive
    send String modulo five rescue false end
  def modfifteen
    modthree and modfive end

  # We've commandeered `to_a` so we can call member functions on `self` without using `.`s.
  #
  # Since we use `for` later on to loop over `[0, 99]`, we need to convert this to looping over
  # `[1,100]`. We do this via `succ`, which simply adds one to `self`. However, we still need to
  # actually perform math on it, so we use the same member function trick again and commandeer
  # `to_hash` to do the heavy lifting, and use `Hash succ`.
  #
  # We need to return an array from `to_a`, so just call it on the return value of `Hash`.
  def to_a
    Array Hash succ
  end

  # The actual heavy lifting: check to see if we're divisible by three or five and print out the
  # corresponding values.
  #
  # Since we are overwriting `to_hash`, we need to return a Hash, so we call `Hash` on `puts` return
  # value, which is `nil`. (And `Hash nil` is just an empty hash.)
  def to_hash
    Hash puts case
              when modfifteen then FizzBuzz nil
              when modthree   then Fizz nil
              when modfive    then Buzz nil
              else                 self
              end
  end
end

# Now to actually iterate from 1 to 100. In newer versions of Ruby, the object id doesn't actually
# directly correspond to the pointer of the object in memory—instead, object ids are assigned only
# when explicitly asked for. They start at 60, and go in multiples of 20. We already accessed the
# object id of the `Integer` class in the previous `for` loop, so we need to do two more: The first
# is here, which will be 80. The next time we access `object_id` (within the `for` loop below), it
# will be 100.
class Dummy
  object_id end

# Iterate over all numbers in the range `[0, 99]`. We call `Array` on them so we can access methods
# defined on them without using punctuation.
for num in object_id do
  Array num
end

