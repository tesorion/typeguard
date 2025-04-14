# frozen_string_literal: true

module Yard
  module Test
    module YardTest
      module NestedOnce
        class NestedClassOne; end

        module NestedTwice
          class NestedClassTwo; end
        end
      end

      class Basic
        # @param lhs [Integer]
        # @param rhs [Integer]
        # @return [Integer]
        def add(lhs, rhs)
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

        # @param klass_instance [Yard::Test::YardTest::NestedOnce::NestedClassOne] nested class one
        # @return [(Yard::Test::YardTest::NestedOnce::NestedClassOne, Yard::Test::YardTest::NestedOnce::NestedTwice::NestedClassTwo)] array of nested classes
        def nested_classes(klass_instance)
          [klass_instance, NestedOnce::NestedTwice::NestedClassTwo.new]
        end
      end
    end
  end
end
