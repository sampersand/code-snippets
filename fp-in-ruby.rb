module FP
	class MultiMethod
		NoMethodMatchesError = Class.new StandardError

		def initialize = @methods = []

		def add(callable, conditions) = @methods.push([callable, conditions])

		def call(...)
			@methods.each do |callable, conditions|
				return callable.(...) if conditions.all? { |condition|
					next true if condition == true
					next false unless condition.respond_to?(:call)
					condition.(...) 
				}
			end

			raise NoMethodMatchesError, "no method matched!"#, caller(1)
		end
	end

	module_function

	def extended(cls)
		unless cls.instance_variable_defined? :@__multi_functions
			cls.instance_variable_set :@__multi_functions, Hash.new { |h, k| h[k] = MultiMethod.new }
		end
	end

	def multi(func_=nil, func: func_, where: [true])
		where = [where] if where.respond_to? :call

		@__multi_functions[func].add method(func), where

		define_method func do |*a, **k, &b|
			@__multi_functions[func].(*a, **k, &b)
		end
	end
end

extend FP

multi def fib(x) = x,
   where: proc { _1 <= 1 }
multi def fib(x) = fib(x - 1) + fib(x - 2)

10.times do |x|
    puts fib x
end
__END__
def square(x) = x ** 2
def add_two(x) = x + 2
puts (square * add_two).(34)

__END__
multi def safe_divide(x, y) = x / y, where: proc { !y.zero? }
def halve(x) = safe_divide(x, 2)

