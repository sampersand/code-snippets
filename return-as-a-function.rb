class Object
    RETURN_ = Object.new
    def return = proc { throw(RETURN_, self) }

    def else(method) = self || method.call

    def self.method_added(name)
        return if $_is_method_being_added
        meth = method(name)

        $_is_method_being_added = true
        define_method name do |*a, **k, &b|
            catch RETURN_ do
                meth.call(*a, **k, &b)
            end
        end
        $_is_method_being_added = false
    end
end

def divide(lhs, rhs)
    rhs.nonzero?.else(nil.return)

    lhs / rhs
end


p divide(3, 0)
