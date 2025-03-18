# frozen_string_literal: true

module Yard::Main
  # typed_modules = Yard::Initializer::YardocInitializer.new('.yardoc').resolve_types
  # Yard::Wrapper::PrependWrapper.new(typed_modules).wrap_all
  builder = Yard::TypeModel::Builder::YardBuilder.new('.yardoc')
  pp builder.build
end
