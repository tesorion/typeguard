# frozen_string_literal: true

require 'test_helper'
require_relative '../assets/yard/basic_yard'

module Yard
  module Test
    class YardValidator < Minitest::Test
      include Yard::Test::YardTest
      include Yard::Test::YardTest::NestedOnce
      include Yard::Test::YardTest::NestedOnce::NestedTwice

      Yard.configure do |config|
        config.enabled = true
        config.source = :yard
        config.target = ['test/assets/yard/basic_yard.rb']
        config.reparse = true
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

      def test_add_number_to_string
        assert_equal('one2', Basic.new.add_number_to_string('one', 2))
      end

      def test_add_with_splat_argument
        assert_equal(16, Basic.new.add_with_splat_argument(10, 1, 2, 3))
      end

      def test_add_with_optional_argument
        assert_equal(3, Basic.new.add_with_optional_argument(1, 2))
        assert_equal(3.0, Basic.new.add_with_optional_argument(2))
      end

      def test_add_with_incorrect_optional_argument
        assert_raises(TypeError, 'it cannot have float as default') { Basic.new.add_with_incorrect_optional_argument(1) }
      end

      def test_add_with_keyword_arguments
        assert_equal(3, Basic.new.add_with_keyword_arguments(lhs: 1, rhs: 2))
      end

      def test_add_with_keyword_arguments_with_default
        assert_equal(3, Basic.new.add_with_keyword_arguments_with_default(lhs: 2))
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

      def test_hash_rocket_works
        assert_equal(
          Hash['first' => 1, 'returned' => 'return_value'],
          Basic.new.hash_rocket(Hash['first' => 1]),
          'it can process special typed hash syntax'
        )
      end

      def test_hash_rocket_raises_key_error
        assert_raises(TypeError, 'it cannot have integer keys') { Basic.new.hash_rocket(Hash[1 => 2]) }
      end

      def test_hash_rocket_raises_value_error
        assert_raises(TypeError, 'it cannot have symbol values') { Basic.new.hash_rocket(Hash['first' => :a]) }
      end

      def test_fixed_numeric_hash_works
        assert_equal(Hash[1 => 5.0], Basic.new.fixed_hash(1, 4.0), 'it can distinguish fixed hash types')
      end

      def test_fixed_numeric_hash_raises_key_error
        assert_raises(ArgumentError, 'it cannot have string keys') { Basic.new.fixed_hash(Hash['1' => 2]) }
      end

      def test_fixed_numeric_hash_raises_value_error
        assert_raises(ArgumentError, 'it cannot have string values') { Basic.new.fixed_hash(Hash[1 => '2']) }
      end

      def test_duck_push_works_with_array
        assert_equal([5, [1]], Basic.new.duck_push([5], [1]), 'it can push arrays')
      end

      def test_duck_push_raises_with_symbol
        assert_raises(TypeError, 'it cannot push symbols') { Basic.new.duck_push([5], :sym) }
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

      def test_attr_writer
        b = Basic.new
        assert_equal(1, (b.writer = 1))
      end

      def test_document_without_types
        assert_equal(7, Basic.new.document_without_types(3, 4), 'it supports arguments without types')
        assert_equal('ab', Basic.new.document_without_types('a', 'b'), 'it supports arguments without types')
      end

      def test_add_without_yardoc
        assert_equal(7, Basic.new.add_without_yardoc(3, 4), 'it supports arguments without yardoc')
        assert_equal('ab', Basic.new.add_without_yardoc('a', 'b'), 'it supports arguments without yardoc')
      end

      def test_block_without_yardoc
        assert_equal(444, Basic.new.block_without_yardoc { |i| 321 + i }, 'it supports blocks without yardoc')
        assert_equal('123', Basic.new.block_without_yardoc(&:to_s), 'it supports blocks without yardoc')
      end

      def test_add_with_partial_yardoc
        assert_equal(7, Basic.new.add_with_partial_yardoc(3, 4), 'it supports arguments with partial yardoc')
        assert_raises(TypeError, 'it checks typed parameters') { Basic.add_as_class_method(3, 4.0) }
      end

      def test_add_with_return_yardoc
        assert_equal(7, Basic.new.add_with_partial_yardoc(3, 4), 'it supports arguments without yardoc')
        assert_raises(TypeError, 'it checks typed return') { Basic.add_as_class_method('a', 'b') }
      end

      def test_class_method
        assert_equal(7, Basic.add_as_class_method(3, 4), 'it can add integer values')
      end

      def test_class_method_raises
        assert_raises(TypeError, 'it cannot add strings') { Basic.add_as_class_method('a', 'b') }
      end
    end
  end
end
