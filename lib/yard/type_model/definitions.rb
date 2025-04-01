# frozen_string_literal: true

module Yard
  module TypeModel
    module Definitions
      TypeNode = Struct.new(:kind, :shape, :children, :metadata, keyword_init: true)
      ModuleDefinition = Struct.new(:name, :source, :type_parameters, :children)
      ClassDefinition = Struct.new(:name, :source, :parent, :type_parameters, :children)
      MethodDefinition = Struct.new(:name, :source, :scope, :visibility, :parameters, :returns)
      ParameterDefinition = Struct.new(:name, :source, :types, :type_strings)
      ReturnDefinition = Struct.new(:source, :types, :type_strings)
    end
  end
end
