# frozen_string_literal: true

require 'test_helper'
require 'rbs'
require 'yard/type_model/builder/rbs_builder'

module Yard
  module Test
    class RBSBuilderTest < Minitest::Test
      include Yard::TypeModel::Definitions
      include Yard::TypeModel::Builder

      def test_builder_empty_warning
        assert_output(/WARNING/) do
          Yard::TypeModel::Builder::RBSBuilder.new('test/assets/empty', false)
        end
      end

      def test_builder_filled_silent
        assert_silent do
          Yard::TypeModel::Builder::RBSBuilder.new('test/assets/', false)
        end
      end
    end
  end
end
