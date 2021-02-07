# Emulate php in ruby! This time, it's arrays.
$array = array(1, 2, 'foo' => 45);

$array[] = 'hi';

BEGIN {
class PhpArray < Hash
    def initialize(*a, **k)
        merge! k
        merge! a.each_with_index.map { [_2, _1] }.to_h
    end

    def []=(*args)
        if args.length == 1
            args.unshift keys.select { _1.is_a? Integer }.max.succ
        end

        super(*args)
    end
end

module Kernel
    alias echo print
    def array(...) = PhpArray.new(...)
end
}
