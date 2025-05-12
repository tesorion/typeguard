# frozen_string_literal: true

module Yard
  module TypeModel
    module Definitions
      TypeNode = Struct.new(:kind, :shape, :children, :metadata, keyword_init: true)
      ModuleDefinition = Struct.new(:name, :source, :vars, :type_parameters, :children, keyword_init: true)
      ClassDefinition = Struct.new(:name, :source, :vars, :parent, :type_parameters, :children, keyword_init: true)
      MethodDefinition = Struct.new(:name, :source, :scope, :visibility, :parameters, :returns, keyword_init: true)
      ParameterDefinition = Struct.new(:name, :source, :default, :types, :types_string, keyword_init: true)
      ReturnDefinition = Struct.new(:source, :types, :types_string, keyword_init: true)
      VarDefinition = Struct.new(:name, :source, :scope, :types, :types_string, keyword_init: true)
    end
  end
end
