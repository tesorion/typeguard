# frozen_string_literal: true

module Typeguard
  module Test
    module YardTest
      module NestedOnce
        class NestedClassOne; end

        module NestedTwice
          class NestedClassTwo; end
        end
      end

      class Basic
        def initialize; end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def add(lhs, rhs)
          lhs + rhs
        end

        # The argument order is swapped, arguments are interpreted incorrectly
        # @param rhs [Integer]
        # @param lhs [String]
        # @return [String]
        def add_number_to_string(lhs, rhs)
          lhs + rhs.to_s
        end

        # @param base [Integer]
        # @param arr [Array<Integer>]
        # @return [Integer]
        def add_with_splat_argument(base, *arr)
          arr.sum(base)
        end

        # @param [Hash] kwargs
        # @option kwargs [Integer] :lhs
        # @option kwargs [Integer] :rhs
        # @return [Integer]
        def add_with_kwsplat_argument(**kwargs)
          kwargs.fetch(:lhs) + kwargs.fetch(:rhs)
        end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def add_with_nokwsplat_argument(lhs, rhs, **nil)
          lhs + rhs
        end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def add_with_optional_argument(lhs, rhs = 1)
          lhs + rhs
        end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def add_with_incorrect_optional_argument(lhs, rhs = 1.0)
          lhs + rhs
        end

        # @param foo [nil]
        # @param bar [String]
        # @return [(NilClass, String)]
        def nil_optional(foo = nil, bar = 'nil')
          [foo, bar]
        end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def add_with_keyword_arguments(lhs:, rhs:)
          lhs + rhs
        end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def add_with_keyword_arguments_with_default(lhs:, rhs: 1)
          lhs + rhs
        end

        def add_with_keyword_arguments_with_default_without_doc(lhs:, rhs: 1)
          lhs + rhs
        end

        # @param arr [Array<Integer>] array of integers
        # @return [Integer] sum of array
        def total(arr)
          arr.sum
        end

        # @param arr [Array(String, Integer)] fixed array of string and integer
        # @return [Array(String, Integer, String)]
        def fixed_array(arr)
          arr << arr.last.succ.to_s
        end

        # @param hash [Hash{String => Integer, Float}] hash with one key and two value types
        # @return [Hash{String, Symbol => Integer, Float, String}] hash with added value type
        def hash_rocket(hash)
          hash['returned'] = 'return_value'
          hash
        end

        # @param key_type [Numeric] numeric key
        # @param value_type [Numeric] numeric value
        # @return [Hash<Numeric, Numeric>] hash with numeric key and numeric value
        def fixed_hash(key_type, value_type)
          Hash[key_type => (key_type + value_type)]
        end

        # @param pushable [#push] object responds to :push
        # @param element [#push] element to push responds to :push
        # @return [#push] the pushable object with the element added
        def duck_push(pushable, element)
          pushable.push(element)
        end

        # @param klass_instance [Typeguard::Test::YardTest::NestedOnce::NestedClassOne] nested class one
        # @return [(Typeguard::Test::YardTest::NestedOnce::NestedClassOne, Typeguard::Test::YardTest::NestedOnce::NestedTwice::NestedClassTwo)] array of nested classes
        def nested_classes(klass_instance)
          [klass_instance, NestedOnce::NestedTwice::NestedClassTwo.new]
        end

        # @param value [Integer]
        # @return [Integer]
        def writer=(value)
          value.to_s
        end

        # @param lhs
        # @param rhs
        # @return the sum of lhs and rhs
        def document_without_types(lhs, rhs)
          lhs + rhs
        end

        def add_without_yardoc(lhs, rhs)
          lhs + rhs
        end

        def add_optional_without_yardoc(lhs, rhs = 1)
          lhs + rhs
        end

        def add_optional_expression_without_yardoc(lhs, rhs = lhs + 1)
          lhs + rhs
        end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def test_add_rest_args(lhs, rhs, *)
          lhs + rhs
        end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def test_add_rest_keywords(lhs, rhs, **)
          lhs + rhs
        end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def test_add_rest_block(lhs, rhs, &)
          lhs + rhs
        end

        def add_optional_parentheses_expression_without_yardoc(lhs, rhs = (; lhs + 1))
          lhs + rhs
        end

        def block_without_yardoc(&block)
          block.call(123)
        end

        # @param rhs [Integer]
        def add_with_partial_yardoc(lhs, rhs)
          lhs + rhs
        end

        # @return [Integer]
        def add_with_return_yardoc(lhs, rhs)
          lhs + rhs
        end

        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def self.add_as_class_method(lhs, rhs)
          lhs + rhs
        end

        # This currently breaks with the instance method `add`
        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def self.add(lhs, rhs)
          lhs + rhs
        end
      end
    end
  end
end
