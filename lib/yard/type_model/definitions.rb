module Yard
  module TypeModel
    # NOTE: :source is .rb for YARD and .rbs for RBS
    class ModuleDefinition
      attr_reader :name, :source, :type_parameters, :members

      def initialize(name:, source:, type_parameters:, members:)
        @name = name
        @source = source
        @type_parameters = type_parameters
        @members = members
      end
    end

    class ClassDefinition
      attr_reader :name, :source, :parent, :type_parameters, :members

      def initialize(name:, source:, parent:, type_parameters:, members:)
        @name = name
        @source = source
        @parent = parent
        @type_parameters = type_parameters
        @members = members
      end
    end

    class MethodDefinition
      attr_reader :name, :source, :scope, :visibility, :parameters, :returns

      def initialize(name:, source:, scope:, visibility:, parameters:, returns:)
        @name = name
        @source = source # a.rb 10:5
        @scope = scope # instance/class method
        @visibility = visibility
        @parameters = parameters
        @returns = returns
      end
    end

    class ParameterDefinition
      attr_reader :name, :source, :type_node

      def initialize(name:, source:, type_node:)
        @name = name
        @source = source
        @type_node = type_node
      end
    end

    module TypeShapes
      SIMPLE  = :simple
      GENERIC = :generic
      UNION   = :union
      TUPLE   = :tuple
    end

    TypeNode = Struct.new(:kind, :shape, :children, :metadata, keyword_init: true)
  end
end
