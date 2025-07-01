# frozen_string_literal: true

require 'test_helper'
require 'rbs'
require 'typeguard/type_model/builder/rbs_builder'

module Typeguard
  module Test
    class RBSBuilderTest < Minitest::Test
      include Typeguard::TypeModel::Definitions
      include Typeguard::TypeModel::Builder

      def test_builder_empty_warning
        assert_output(/WARNING/) do
          Typeguard::TypeModel::Builder::RBSBuilder.new('test/assets/empty', false)
        end
      end

      def test_builder_filled_silent
        assert_silent do
          Typeguard::TypeModel::Builder::RBSBuilder.new('test/assets/', false)
        end
      end
    end
  end
end
