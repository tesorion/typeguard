class Calc
  # @param x [Integer]
  def initialize(x); end

  # @return somevar [Integer]
  attr_accessor :somevar

  # @param [Integer, Float] lhs
  # @param [Integer, Array<Integer, Array<Float>>] rhs
  # @return [Integer, Float] Addition
  def sum(lhs, rhs)
    lhs + Array(rhs).flatten.sum
  end
  protected :sum

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

  # # @param [#to_s] obj
  # # @return [String] Object to string
  # def ducky(obj)
  #   obj.to_s
  # end

  # # @param [#read] obj
  # # @return [void]
  # def read_ducky(obj)
  #   obj.read
  # end
end

# Something something
# @return [Integer]
def z
  1
end
