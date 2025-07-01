# frozen_string_literal: true

module Typeguard
  module Resolution
    class Resolver
      include Typeguard::TypeModel::Definitions

      def initialize(definitions, config)
        @definitions = definitions
        @config = config
      end

      def resolve!
        if @config.raise_on_name_error
          @definitions.each do |definition|
            resolve_definition(definition)
          rescue NameError => e
            raise(e.class,
                  Metrics.format_log(Metrics.report(Object, definition, :unresolved, 'resolution', e.message)),
                  [])
          end
        else
          # Create compact array of resolved definitions
          resolve_prune_definitions!
        end
      end

      def resolve_definition(definition)
        case definition
        when ModuleDefinition, ClassDefinition
          Object.const_get(definition.name.to_s, true)
          definition.children.each { |child| resolve_definition(child) }
        when MethodDefinition
          definition.parameters.each { |param| param.types.each { |node| resolve_type(node) } }
          return if definition.name == :initialize # Ignore YARD default tag

          definition.returns.types.each { |node| resolve_type(node) }
        else raise "Unexpected definition for '#{definition}'"
        end
      end

      def resolve_prune_definitions!(definitions = @definitions, parent = Object)
        definitions.grep_v(MethodDefinition) do |definition|
          definition.children = resolve_prune_definitions!(definition.children, definition)
        end
        definitions.reject do |definition|
          case definition
          when ModuleDefinition, ClassDefinition
            Object.const_get(definition.name.to_s, true)
          when MethodDefinition
            definition.parameters.each { |param| param.types.each { |node| resolve_type(node) } }
            next if definition.name == :initialize # Ignore YARD default tag

            definition.returns.types.each { |node| resolve_type(node) }
          end
          false
        rescue NameError => e
          Metrics.report(parent, definition, :unresolved, 'resolution', e)
          true
        end
      end

      # Raises a NameError if module names are not found
      def resolve_type(node)
        case node.shape
        when :basic
          node.metadata[:const] ||= Object.const_get(node.kind.to_s, true)
        when :generic, :fixed
          node.metadata[:const] ||= Object.const_get(node.kind.to_s, true)
          node.children.each { |child_node| resolve_type(child_node) }
        when :hash, :fixed_hash
          node.metadata[:const] ||= Object.const_get(node.kind.to_s, true)
          node.children.flatten.each { |child_node| resolve_type(child_node) }
        when :union
          node.children.each { |child_node| resolve_type(child_node) }
        when :literal
          # The mapper has already rejected invalid literals,
        when :duck
          # Resolving duck-types at this point is unreliable
          # and slow, leaving it up to runtime checks
        when :untyped
          # Always correct
        else raise "Unknown node shape: #{node.shape}"
        end
      end
    end
  end
end
