class Example
  # @param [Integer, Float] lhs
  # @param [Integer, Array<Integer, Array<Float>>] rhs
  # @return [Integer, Float] Addition
  def sum(lhs, rhs)
    lhs + Array(rhs).flatten.sum
  end

  # @param (see #sum)
  # @return [Float] Subtraction
  # @note Random text
  def sub(lhs, rhs)
    lhs - rhs.to_f
  end

  # @return [void] nothing
  def priv; end
  private :priv

  # @param [Symbol] k
  # @param [Array<Hash>] v
  # @return [Hash] o
  def dict(k, v)
    o = {}
    o[k] = v.map(&:values).flatten
    o
  end

  # @param [FalseClass] in
  # @return [TrueClass] out
  # @note The convention is actually Boolean, but that type does not exist.
  def truthy(expression)
    !expression
  end
  protected :truthy

  # @param [#to_s] obj
  # @return [String] Object to string
  def ducky(obj)
    obj.to_s
  end

  # @param [#push] obj
  # @return [void]
  def push_ducky(obj)
    obj.push(1)
  end
end

# Something something
# @return [Integer]
def z
  1
end

# yardoc lib/yard/validator/example.rb && ruby lib/yard/validator/example.rb
require_relative '../validator'
Yard::Main.load_enable_yard('.yardoc')
example = Example.new
example.sub(1, 5)
example.dict(:something, [{ a: 1 << 1, b: 1 << 2 }])
example.ducky(BasicObject)
example.push_ducky([])
# Sum raises an error, expected float for last number: Array<Integer, Array<Float>>
example.sum(1, [2, 4, 8, [1.0, 2.0, 2.5, 3.0], 16, [0.5, 5]])
