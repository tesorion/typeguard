# frozen_string_literal: true

require 'test_helper'
require_relative '../assets/rbs/basic_rbs'

module Yard
  module Test
    class RBSValidator < Minitest::Test
      include Yard::Test::RBSTest
      include Yard::Test::RBSTest::NestedOnce
      include Yard::Test::RBSTest::NestedOnce::NestedTwice

      Yard.configure do |config|
        config.enabled = true
        config.source = :rbs
        config.target = 'test/assets/rbs'
        config.reparse = false
        config.at_exit_report = false
        config.resolution.raise_on_name_error = true
        config.validation.raise_on_unexpected_argument = true
        config.validation.raise_on_unexpected_return = true
      end.process!

      def test_that_it_has_a_version_number
        refute_nil(::Yard::Validator::VERSION)
      end

      def test_add_works_with_integers
        assert_equal(7, Basic.new.add(3, 4), 'it can add integer values')
      end

      def test_add_raises_with_strings
        assert_raises(TypeError, 'it cannot add strings') { Basic.new.add('a', 'b') }
      end

      def test_total_works_with_integer_array
        assert_equal(10, Basic.new.total([3, 3, 4]), 'it can add integer arrays')
      end

      def test_total_raises_with_float_array
        assert_raises(TypeError, 'it cannot have floats') { Basic.new.total([1, 2, 3.0]) }
      end

      def test_fixed_array_works_ordered
        assert_equal(['1', 2, '3'], Basic.new.fixed_array(['1', 2]), 'it can process fixed arrays')
      end

      def test_fixed_array_raises_unordered
        assert_raises(TypeError, 'it cannot have unordered arrays') { Basic.new.fixed_array([1, '2']) }
      end

      def test_nested_custom_classes_work
        actual = Basic.new.nested_classes(NestedClassOne.new)
        assert_kind_of(NestedClassOne, actual.first, 'it can process nested classes once')
        assert_kind_of(NestedClassTwo, actual.last, 'it can process nested classes twice')
      end

      def test_nested_custom_classes_raise
        assert_raises(TypeError, 'it cannot process nested class mismatches') do
          Basic.new.nested_classes(NestedClassTwo.new)
        end
      end
    end
  end
end
