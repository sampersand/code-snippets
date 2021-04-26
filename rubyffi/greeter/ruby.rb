require 'fiddle'
require 'fiddle/import'

module Greeter
    extend Fiddle::Importer
    DEFAULT_LIB_PATH = './greeter.so'

    dlload ENV.fetch('LIB_PATH', DEFAULT_LIB_PATH)

    Person = struct ['char *name', 'int age']
    extern 'void greet(struct person *person);'
end

include Greeter

me = Person.malloc
me.name = 'samp'
me.age = 23
Greeter.greet me
