# A very simplistic vm in ruby to show what a vm looks like.

class Vm
	OP_NOOP       = 0
	OP_JMP        = 1
	OP_JMP_ZERO   = 2
	OP_JMP_NONZERO= 3
	OP_HALT       = 4
	OP_LOAD_CONST = 5
	OP_PRINT      = 6

	OP_ADD        = 7
	OP_SUB        = 8
	OP_MUL        = 9
	OP_DIV        = 10
	OP_NEG        = 11
	OP_EQL        = 12


	def initialize(bytecode, constants)
		@bytecode = bytecode
		@constants = constants
		@pointer = 0
		@locals = []
	end

	def fetch = @bytecode[@pointer].tap { @pointer += 1 }
	def jump(dst) @pointer = dst end

	def run
		loop do
			case (opcode = fetch)
			when OP_NOOP
				# do nothing

			when OP_JMP
				jump fetch

			when OP_JMP_ZERO, OP_JMP_NONZERO
				if @locals[fetch].zero? == (opcode == OP_JMP_ZERO)
					jump fetch
				else
					fetch # still have to advance even if we ignore it
				end

			when OP_HALT
				return

			when OP_LOAD_CONST
				const = @constants[fetch]
				@locals[fetch] = const # be explicit about order of `fetch`es.

			when OP_PRINT
				puts @locals[fetch]

			when OP_NEG 
				index = fetch
				@locals[index] = -index

			when OP_ADD
				lhs = @locals[fetch]
				rhs = @locals[fetch]
				@locals[fetch] = lhs + rhs

			when OP_SUB
				lhs = @locals[fetch]
				rhs = @locals[fetch]
				@locals[fetch] = lhs - rhs

			when OP_MUL
				lhs = @locals[fetch]
				rhs = @locals[fetch]
				@locals[fetch] = lhs * rhs

			when OP_DIV
				lhs = @locals[fetch]
				rhs = @locals[fetch]
				@locals[fetch] = lhs / rhs

			when OP_EQL
				lhs = @locals[fetch]
				rhs = @locals[fetch]
				@locals[fetch] = (lhs == rhs) ? 1 : 0 # we only deal in numbers
			else
				raise "[bug] unknown opcode '#{opcode}"
			end
		end
	end
end

# Normally the bytecode would be built by a compiler, but let's just do it ourselves.
@consts = []
@code = []

def const(what) = @consts.index(what) || @consts.push(what).length.pred

def op(name, *args)
	@code.push Vm.const_get(:"OP_#{name.upcase}")
	@code.concat args
end

def local(index) = index # just a noop to make life easier


# i = 0
# 
# do { 
# 	i = i + 1
# } while i != 10
# 
# print i
op :load_const, const(0), local(0)             # l0 = 0

while_loop_top = @code.length                  # while_loop_top:
op :load_const,  const(1), local(1)            #    l1 = 1
op :add,         local(0), local(1), local(0)  #    l0 = l0 + l1
op :load_const,  const(10), local(2)           #    l2 = 10
op :eql,         local(0), local(2), local(3)  #    l3 = l0 == l2
op :jmp_zero,    local(3), while_loop_top      #    if l3 == 0; goto while_loop_top
op :print,       local(0)                      # puts l0
op :halt                                       # exit

Vm.new(@code, @consts).run
