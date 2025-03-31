# frozen_string_literal: true

# rubocop:disable Naming/MethodParameterName

# Run this example with yardoc bin/example.rb && ruby bin/example.rb

# Custom constant
class Foo; end

# Yardoc validation example
class Example
  # @return [Object] a regular type
  def regular0
    Object
  end

  # @return [true] Ruby literal 'true'
  def literal0
    true
  end

  # @return [#push] duck-type: responds to :push
  def duck0
    []
  end

  # @param a [Integer] Integer to double
  # @return [Integer] double of a
  def double1(a)
    a + a + 0.0
  end

  # @param a [Integer]
  # @param b [Integer]
  # @return [Array<Integer, Float>] generic array of numbers
  def generic_array2(a, b)
    [a * rand, b.to_s]
  end

  # @param a [Integer]
  # @return [Array(Symbol, Integer)] fixed array with order Symbol -> Integer
  def fixed_array1(a)
    [a, a.to_s.to_sym]
  end

  # @param a [Integer]
  # @return [Hash{Symbol => Integer, Float}] special hash syntax with 1 key and 2 value types
  def special_hash1(a)
    { int: a, float: a.to_f, string: a.to_s }
  end

  # @param a [Integer]
  # @return [Hash{Symbol, String => Boolean, Array<Array(Foo, #push, Set<Integer>)>}] complex types
  def complex1(a)
    Array.new(rand(1..8)) { |i| [i.to_s, Array.new(rand(1..4)) { [Foo.new, [], Set[a.to_f]] }] }.to_h
  end

  # @param a [Integer]
  # @return [((Integer, Float), <Symbol>, {Symbol => Integer, Symbol})] shorthands for collections
  def shorthands1(a)
    [[a, a * 0.5], %i[a b], { a: :a, b: a, c: a.to_f }]
  end
end

require_relative '../lib/yard/validator'
Yard::Main.load_enable_yard('.yardoc')
at_exit { Yard::Metrics.flush }

example = Example.new
example_methods = Example.instance_methods(false)
example_methods.shuffle!
pad = (1 << (example_methods.length - 1)).to_s.length
args = ->(n) { Array.new([n, 0].max) { rand(1..(1 << 32)) } }

example_methods.each_with_index do |method_name, i|
  # The wrapping process has modified the arity/parameters
  # of the unbound method, using a workaround to infer param count.
  param_count = method_name[-1].to_i
  n = 1 << i
  puts "#{n.to_s.rjust(pad)}x :#{method_name}"
  n.times { example.send(method_name, *args.call(param_count)) }
end

# rubocop:enable Naming/MethodParameterName
