module Yard
  module TypeModel
    module Builder
      class YardBuilder
        include Yard::TypeModel::Definitions
        require 'yard'

        def initialize(target)
          YARD::Registry.load!(target)
        end

        def build
          YARD::Registry.root.children.map { |child| build_object(child) }.compact
        end

        def build_object(object)
          case object
          when YARD::CodeObjects::NamespaceObject
            members = object.children.map { |child| build_object(child) }.compact

            # TODO: handle initializer parameters
            if object.is_a?(YARD::CodeObjects::ClassObject)
              ClassDefinition.new(
                name: object.path,
                source: "#{object.file}:#{object.line}",
                parent: object.superclass&.path,
                type_parameters: nil,
                members: members
              )
            else
              ModuleDefinition.new(
                name: object.path,
                source: "#{object.file}:#{object.line}",
                type_parameters: nil,
                members: members
              )
            end
          when YARD::CodeObjects::MethodObject
            parameters = object.tags(:param).map do |tag|
              ParameterDefinition.new(
                name: tag.name.to_sym,
                source: "#{object.file}:#{object.line}",
                types: build_types(tag)
              )
            end
            MethodDefinition.new(
              name: object.name,
              source: "#{object.file}:#{object.line}",
              scope: object.scope,
              visibility: object.visibility,
              parameters: parameters,
              returns: build_types(object.tag(:return))
            )
          when YARD::CodeObjects::ConstantObject, YARD::CodeObjects::ClassVariableObject
            raise "Not implemented: #{object.class}"
          else
            raise "Unsupported YARD object: #{object.class}"
          end
        end

        def build_types(tag)
          types = tag.respond_to?(:types) ? tag.types : []
          case types.size
          when 0
            TypeNode.new(
              kind: :untyped,
              shape: :empty,
              children: [],
              metadata: { note: 'Types specifier list is empty: untyped' }
            )
          when 1
            Yard::TypeModel::Parser::YardParser.parse(tag.types.first)
          else
            children = tag.types.map { |t| Yard::TypeModel::Parser::YardParser.parse(t) }
            TypeNode.new(
              kind: :types,
              shape: :union,
              children: children,
              metadata: { note: 'Object is one of the types defined by children' }
            )
          end
        end
      end

      class RBSBuilder
        require 'rbs'
        def initialize(target)
          rbs_loader = RBS::EnvironmentLoader.new(core_root: nil)
          rbs_loader.add(path: Pathname(target))
          @rbs_env = RBS::Environment.from_loader(rbs_loader)
        end
      end
    end
  end
end
