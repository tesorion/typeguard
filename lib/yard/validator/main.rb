# frozen_string_literal: true

module Yard
  module Main
    # TODO: move
    def self.load_enable_yard(target, reparse_files)
      definitions = Yard::TypeModel::Builder.yard.new(target, reparse_files).build
      Yard::Resolution::Resolver.new(definitions).resolve!
      Yard::Validation::Wrapper.new(definitions).wrap!
    end
  end
end
