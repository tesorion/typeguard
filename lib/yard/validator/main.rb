# frozen_string_literal: true

module Yard::Main
  # TODO: move
  def self.load_enable_yard(target)
    definitions = Yard::TypeModel::Builder::YardBuilder.new(target).build
    Yard::Resolution::Resolver.new(definitions).resolve!
    Yard::Validation::Wrapper.new(definitions).wrap!
  end
end
