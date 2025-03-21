# Eager resolution followed by fast wrapper (ignore splat operators for now)
# Redifining the method avoids overhead and traceability: same method in call stack
# Sorbet-runtime does not support Prepend for perf/simplicity
# Sorbet-runtime also removes hooks by restoring the original when no longer needed
# This does change the source of methods!

# TODO: typenode resolution, recursively const_get type?
# Type resolution is straightforward dynamically, but difficult
# statically; need to create a constant table from the ASTs
# and raise an error if a name (ConstantReadNode) is not found in it

module Metrics
  @registry = {}

  def self.get_counter(klass, method_name)
    @registry[klass] ||= {}
    @registry[klass][method_name] ||= Counter.new
  end

  def self.flush
    @registry.each do |klass, method_counters|
      method_counters.each do |method_name, counter|
        puts "Flushing #{klass}##{method_name}: #{counter.value} calls"
        counter.reset!
      end
    end
  end

  class Counter
    attr_reader :value

    def initialize
      @value = 0
    end

    def increment
      @value += 1
    end

    def reset!
      @value = 0
    end
  end
end

class Example
  def initialize(a)
    @a = a
    @b = a << a
  end

  def somefunc(x)
    @a + x
  end
end

# Defined as a private instance method of Object
# Object.method(:sq)
def sq(x)
  x * x
end

def wrap(klass, method_name)
  original_method = klass.instance_method(method_name)
  counter = Metrics.get_counter(klass, method_name)
  klass.define_method(method_name) do |*args, &blk|
    raise TypeError, 'Not an integer' unless args[0].is_a?(Integer)

    counter.increment
    result = original_method.bind(self).call(*args, &blk)
    raise TypeError, 'Result is not an integer' unless result.is_a?(Integer)

    result
  end
end

# TODO: wrap everything in YARD Registry / RBS Environment

wrap(Object, :sq)
sq(2.0)
