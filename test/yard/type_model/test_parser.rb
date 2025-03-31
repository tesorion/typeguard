# frozen_string_literal: true

require 'test_helper'
require 'yard'
require 'yard/type_model/parser/yard_parser'

module Yard
  module Test
    class YardParserTest < Minitest::Test
      include Yard::TypeModel::Definitions
      include Yard::TypeModel::Parser

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
        result = YardParser.parse_map('Foo')
        expected = TypeNode.new(kind: :Foo, shape: :basic, children: [], metadata: {})
        assert_node_equal expected, result
      end

      def test_true_literal
        result = YardParser.parse_map('true')
        expected = TypeNode.new(kind: :true, shape: :literal, children: [],
                                metadata: {})
        assert_node_equal expected, result
      end

      def test_duck_type
        result = YardParser.parse_map('#read')
        expected = TypeNode.new(kind: :"#read", shape: :duck, children: [],
                                metadata: {})
        assert_node_equal expected, result
      end

      def test_generic_array_with_duck
        result = YardParser.parse_map('Array<String, Symbol, #read>')
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
        result = YardParser.parse_map('Set<Number>')
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
        result = YardParser.parse_map('Array(String, Symbol)')
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

      def test_hash_explicit
        result = YardParser.parse_map('Hash{String => Symbol, Number}')
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
        result = YardParser.parse_map('{Foo, Bar => Symbol, Number}')
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
        result = YardParser.parse_map('<String, Symbol>')
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
        result = YardParser.parse_map('(String, Boolean)')
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
        result = YardParser.parse_map('Array<String, Array<Integer, Array<Hash>>>')
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
