module Yard
  module TypeModel
    module Builder
      class YardBuilder
        require 'yard'
        # Types specifier list = [String, Array<String>, nil]
        # Parametrized types = Array<string, Fixnum>
        # Hashes = Hash{KeyTypes=>ValueTypes} or Hash<KeyType, ValueType>
        # Order-dependent lists = Array(String, Fixnum, Hash)
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

            if object.is_a?(YARD::CodeObjects::ClassObject)
              ClassDefinition.new(
                name: object.path,
                source: "#{object.file}:#{object.line}",
                parent: object.superclass&.path,
                type_parameters: build_type_parameters(object),
                members: members
              )
            else
              ModuleDefinition.new(
                name: object.path,
                source: "#{object.file}:#{object.line}",
                type_parameters: build_type_parameters(object),
                members: members
              )
            end
          when YARD::CodeObjects::MethodObject
            parameters = object.tags(:param).map do |tag|
              ParameterDefinition.new(
                name: tag.name.to_sym,
                source: "#{object.file}:#{object.line}",
                type_node: build_type_node(tag.types ? tag.types.join(', ') : 'Object')
              )
            end

            MethodDefinition.new(
              name: object.name,
              source: "#{object.file}:#{object.line}",
              scope: object.scope,
              visibility: object.visibility,
              parameters: parameters,
              returns: build_type_node(object.tag(:return)&.types ? object.tag(:return).types.join(', ') : 'Object')
            )
          when YARD::CodeObjects::ConstantObject, YARD::CodeObjects::ClassVariableObject
            raise "Not implemented: #{object.class}"
          else
            raise "Unsupported YARD object: #{object.class}"
          end
        end

        def build_type_parameters(namespace_object)
          []
        end

        def split_comma(str)
          tokens = []
          current = ''
          level = 0
          str.each_char do |char|
            case char
            when '<'
              level += 1
              current << char
            when '>'
              level -= 1 if level.positive?
              current << char
            when ','
              if level.zero?
                tokens << current.strip
                current = ''
              else
                current << char
              end
            else
              current << char
            end
          end
          tokens << current.strip unless current.strip.empty?
          tokens
        end

        def build_type_node(type_string, inside_generic: false)
          type_string = type_string.strip
          parts = split_comma(type_string)
          if !inside_generic && parts.size > (1)
            children = parts.map { |part| build_type_node(part, inside_generic: false) }
            return TypeNode.new(kind: nil, shape: TypeShapes::UNION, children: children, metadata: {})
          end
          if type_string.include?('<') && type_string.end_with?('>')
            outer_index = type_string.index('<')
            outer_type = type_string[0...outer_index].strip
            inner_part = type_string[(outer_index + 1)...-1].strip
            inner_tokens = split_comma(inner_part)
            children = inner_tokens.map { |t| build_type_node(t, inside_generic: true) }
            shape = children.size > 1 ? TypeShapes::TUPLE : TypeShapes::GENERIC
            return TypeNode.new(kind: outer_type, shape: shape, children: children, metadata: {})
          end
          TypeNode.new(kind: type_string, shape: TypeShapes::SIMPLE, children: [], metadata: {})
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
