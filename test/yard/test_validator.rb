# frozen_string_literal: true

require "test_helper"

class Basic
  # @param [Integer] lhs
  # @param [Integer] rhs
  # @return [Integer]
  def add(lhs, rhs)
    lhs + rhs
  end
end

class Yard::TestValidator < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Yard::Validator::VERSION
  end

  def test_add_works_with_integer
    assert_equal(7, Basic.new.add(3, 4), 'it can add integer values')
  end

  def test_add_works_with_strings
    assert_equal('ab', Basic.new.add('a', 'b'), 'It can add strings, even though the signature does not match')
  end
end
