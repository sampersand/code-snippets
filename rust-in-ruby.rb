# Silly little exmaple of how you can use Ruby's syntax to emulate rust code.
#
# There's only three places where ruby differs from rust here:
# - `Person {{ ... }}` and `Self {{ ... }}`, as `function { key: value }` isn't valid ruby
# - `=>` instead of `->`, as `->` is not a valid token in ruby.


#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Person {{
	age: u32,
	name: String
}}

impl Person {
	fn new(age: u32, name: String) => Self {
		Self {{ age: age, name: name }}
	}

	fn greet(self, who: String) {
		println!("Hello, I'm {} ({} years old). How are you, {}?", self.name, self.age, who)
	}
}

fn main() {
	let me = Person::new(22, "samp".to_string());
	me.greet("friend");
}


#### IMPLEMENTATION BEGINS HERE ####
BEGIN {
def pub(*) end

END { main }

class UndefObj
	attr_accessor :name, :args, :kwargs, :block, :parent

	def initialize(name=nil, *args, **kwargs, &block)
		@name, @args, @kwargs, @block = name, args, kwargs, block
	end

	def call(*a, **k, &b)
		x = UndefObj.new(*a, **k, &b)
		x.parent = self
		x
	end
end

class String ; def to_hash; end; alias to_string to_str end

module Kernel
	define_method(:method_missing, &UndefObj.method(:new))

	def let(arg)
		arg
		# Kernel.const_get(arg.parent.name).__new(arg.block.call)
	end

	def println!(fmt, *a)
		printf(fmt.gsub('%', '%%').gsub('{}', '%s').gsub('{{','{').gsub('}}','}')+"\n", *a)
	end

	def struct(obj)
		Kernel.define_method obj.name, &obj.method(:call)
		keys = obj.block.call.keys
		Kernel.const_set obj.name, Struct.new(*keys) {
			class << self
				alias __new_old new
				undef new
			end
			define_singleton_method :__new do |k| __new_old *keys.map { k[_1] } end
		}
	end

	def impl(cls) 
		Kernel.const_get(cls.parent.name).instance_exec(&cls.block)
	end

	def fn(defn)
		if defn.is_a?(Hash) # ie has a return value
			k, v = defn.to_a.first
			name = k.name
			args = k.kwargs.keys
			rettype = v.name
			block = v.block
		else
			name = defn.name
			args = defn.args + defn.kwargs.keys
			block = defn.block
		end

	
		method(args.first.equal?(self) ? (args.shift; :define_method) : :define_singleton_method).call name do |*given|
			args.zip given do |(name, val)|
				define_singleton_method name do val end
			end

			(ret = instance_exec(&block)).name == rettype ? __new(ret.block.call) : ret
		end
	end
end
}
