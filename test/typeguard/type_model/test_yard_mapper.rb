# frozen_string_literal: true

require 'test_helper'
require 'yard'
require 'typeguard/type_model/mapper/yard_mapper'

module Typeguard
  module Test
    class YardMapperTest < Minitest::Test
      include Typeguard::TypeModel::Definitions
      include Typeguard::TypeModel::Mapper

      def assert_node_equal(expected, actual)
        assert_equal expected.kind, actual.kind
        assert_equal expected.shape, actual.shape
        assert_equal expected.children.size, actual.children.size
        expected.children.zip(actual.children).each do |exp_child, act_child|
          if exp_child.is_a?(Array) && act_child.is_a?(Array)
            assert_equal exp_child, act_child
          else
            assert_node_equal(exp_child, act_child)
          end
        end
        expected_metadata = expected.metadata.dup.tap { |m| m.delete(:note) }
        actual_metadata   = actual.metadata.dup.tap { |m| m.delete(:note) }
        assert_equal expected_metadata, actual_metadata
      end

      def test_basic
        result = YardMapper.parse_map('Foo')
        expected = TypeNode.new(kind: :Foo, shape: :basic, children: [], metadata: {})
        assert_node_equal expected, result
      end

      def test_true_literal
        result = YardMapper.parse_map('true')
        # rubocop:disable Lint/BooleanSymbol
        expected = TypeNode.new(kind: :true, shape: :literal, children: [],
                                metadata: {})
        # rubocop:enable Lint/BooleanSymbol
        assert_node_equal expected, result
      end

      def test_duck_type
        result = YardMapper.parse_map('#read')
        expected = TypeNode.new(kind: :"#read", shape: :duck, children: [],
                                metadata: {})
        assert_node_equal expected, result
      end

      def test_generic_array_with_duck
        result = YardMapper.parse_map('Array<String, Symbol, #read>')
        expected = TypeNode.new(
          kind: :Array,
          shape: :generic,
          children: [
            TypeNode.new(kind: :String, shape: :basic, children: [], metadata: {}),
            TypeNode.new(kind: :Symbol, shape: :basic, children: [], metadata: {}),
            TypeNode.new(kind: :"#read", shape: :duck, children: [],
                         metadata: {})
          ],
          metadata: {}
        )
        assert_node_equal expected, result
      end

      def test_generic_set
        result = YardMapper.parse_map('Set<Number>')
        expected = TypeNode.new(
          kind: :Set,
          shape: :generic,
          children: [
            TypeNode.new(kind: :Number, shape: :basic, children: [], metadata: {})
          ],
          metadata: {}
        )
        assert_node_equal expected, result
      end

      def test_fixed_array
        result = YardMapper.parse_map('Array(String, Symbol)')
        expected = TypeNode.new(
          kind: :Array,
          shape: :fixed,
          children: [
            TypeNode.new(kind: :String, shape: :basic, children: [], metadata: {}),
            TypeNode.new(kind: :Symbol, shape: :basic, children: [], metadata: {})
          ],
          metadata: {}
        )
        assert_node_equal expected, result
      end

      def test_hash_fixed
        result = YardMapper.parse_map('Hash<Numeric, String>')
        expected = TypeNode.new(
          kind: :Hash,
          shape: :hash,
          children: [
            [TypeNode.new(kind: :Numeric, shape: :basic, children: [], metadata: {})],
            [TypeNode.new(kind: :String, shape: :basic, children: [], metadata: {})]
          ],
          metadata: {}
        )
        assert_node_equal expected, result
      end

      def test_hash_explicit
        result = YardMapper.parse_map('Hash{String => Symbol, Number}')
        expected = TypeNode.new(
          kind: :Hash,
          shape: :hash,
          children: [
            [TypeNode.new(kind: :String, shape: :basic, children: [], metadata: {})],
            [
              TypeNode.new(kind: :Symbol, shape: :basic, children: [], metadata: {}),
              TypeNode.new(kind: :Number, shape: :basic, children: [], metadata: {})
            ]
          ],
          metadata: {}
        )
        assert_node_equal expected, result
      end

      def test_hash_shorthand
        result = YardMapper.parse_map('{Foo, Bar => Symbol, Number}')
        expected = TypeNode.new(
          kind: :Hash,
          shape: :hash,
          children: [
            [
              TypeNode.new(kind: :Foo, shape: :basic, children: [], metadata: {}),
              TypeNode.new(kind: :Bar, shape: :basic, children: [], metadata: {})
            ],
            [
              TypeNode.new(kind: :Symbol, shape: :basic, children: [], metadata: {}),
              TypeNode.new(kind: :Number, shape: :basic, children: [], metadata: {})
            ]
          ],
          metadata: {}
        )
        assert_node_equal expected, result
      end

      def test_generic_array_shorthand
        result = YardMapper.parse_map('<String, Symbol>')
        expected = TypeNode.new(
          kind: :Array,
          shape: :generic,
          children: [
            TypeNode.new(kind: :String, shape: :basic, children: [], metadata: {}),
            TypeNode.new(kind: :Symbol, shape: :basic, children: [], metadata: {})
          ],
          metadata: {}
        )
        assert_node_equal expected, result
      end

      def test_fixed_array_with_boolean
        result = YardMapper.parse_map('(String, Boolean)')
        expected_boolean = TypeNode.new(
          kind: :boolean,
          shape: :union,
          children: [
            TypeNode.new(kind: :TrueClass, shape: :basic, children: [], metadata: {}),
            TypeNode.new(kind: :FalseClass, shape: :basic, children: [], metadata: {})
          ],
          metadata: {}
        )
        expected = TypeNode.new(
          kind: :Array,
          shape: :fixed,
          children: [
            TypeNode.new(kind: :String, shape: :basic, children: [], metadata: {}),
            expected_boolean
          ],
          metadata: {}
        )
        assert_node_equal expected, result
      end

      def test_generic_array_nested
        result = YardMapper.parse_map('Array<String, Array<Integer, Array<Hash>>>')
        expected = TypeNode.new(
          kind: :Array,
          shape: :generic,
          children: [
            TypeNode.new(kind: :String, shape: :basic, children: [], metadata: {}),
            TypeNode.new(
              kind: :Array,
              shape: :generic,
              children: [
                TypeNode.new(kind: :Integer, shape: :basic, children: [], metadata: {}),
                TypeNode.new(
                  kind: :Array,
                  shape: :generic,
                  children: [
                    TypeNode.new(kind: :Hash, shape: :basic, children: [], metadata: {})
                  ],
                  metadata: {}
                )
              ],
              metadata: {}
            )
          ],
          metadata: {}
        )
        assert_node_equal expected, result
      end
    end
  end
end
