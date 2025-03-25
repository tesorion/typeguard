# frozen_string_literal: true

module Yard::Main
  builder = Yard::TypeModel::Builder::YardBuilder.new('.yardoc')
  definitions = builder.build
  resolver = Yard::Resolution::Resolver.new(definitions)
  resolver.resolve!
  wrapper = Yard::Validation::Wrapper.new(definitions)
  wrapper.wrap!
  calc = Calc.new(1)
  calc.sub(5, 1)
  calc.dict('sym'.to_sym, [{ a: 1, b: 2 }])
  calc.truthy(false)
  z
end
