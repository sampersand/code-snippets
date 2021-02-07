class Array
	# overwrite the old `[]` method because it's kinda useless...just use `[*...]` or `.to_a(ry)`
	def self.[](type)
		Class.new(Array) do
			const_set :TYPE, type
			def validate(value)
				unless value.is_a?(self.class::TYPE)
					raise TypeError, "expected a #{self.class::TYPE} got a #{value.class}!", caller(1)
				end
			end

			def initialize(*)
				super
				each { validate _1 }
			end

			def push(x) 
				validate(x)
				super
			end

			def self.===(rhs) = rhs.is_a?(Array) && rhs.all? { _1.is_a?(self::TYPE) }
		end
	end
end

case ['a', 'b', 'c']
when Array[Integer] then puts "lots of integers"
when Array[String] then puts "lots of strings" # lots of strings
end

intarry = Array[Integer].new

intarry.push 34 # ok
intarry.push "34" # raises a TypeError
