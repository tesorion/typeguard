# frozen_string_literal: true

require 'test_helper'
require 'yard'
require 'yard/type_model/builder/yard_builder'

module Yard
  module Test
    class YardBuilderTest < Minitest::Test
      include Yard::TypeModel::Definitions
      include Yard::TypeModel::Builder

      def setup
        @test_path = 'test/assets/'
        @builder = Yard::TypeModel::Builder::YardBuilder.new([], false)
      end

      def new_builder(target = ['undocumented'], reparse: true)
        YARD::Registry.clear
        target = Array(target).map { |t| "#{@test_path}#{t}.rb" }
        @builder = Yard::TypeModel::Builder::YardBuilder.new(target, reparse)
      end

      def test_builder_filled_silent
        assert_silent { new_builder('filled').build }
      end

      def test_builder_empty_warning
        assert_output(/WARNING/) { new_builder('empty').build }
      end

      def test_build_module_definition
        module_definition = YARD::CodeObjects::ModuleObject.new(:root, 'Mod')
        actual = @builder.build_object(module_definition)
        expected = ModuleDefinition.new(name: 'Mod', source: ':', children: [])
        assert_equal(expected, actual)
      end

      def test_build_class_definition
        class_definition = YARD::CodeObjects::ClassObject.new(:root, 'Klass')
        actual = @builder.build_object(class_definition)
        expected = ClassDefinition.new(name: 'Klass', source: ':', parent: 'Object', children: [])
        assert_equal(expected, actual)
      end

      def test_build_method_definition
        method_definition = YARD::CodeObjects::MethodObject.new(:root, 'method')
        actual = @builder.build_object(method_definition)
        expected = MethodDefinition.new(
          name: :method,
          source: ':',
          scope: :instance,
          visibility: :public,
          parameters: [],
          returns: ReturnDefinition.new(
            source: ':',
            types: [TypeNode.new(
              kind: :untyped,
              shape: :untyped,
              children: [],
              metadata: { note: 'Types specifier list is empty: untyped' }
            )],
            types_string: []
          )
        )
        assert_equal(expected, actual)
      end
    end
  end
end
