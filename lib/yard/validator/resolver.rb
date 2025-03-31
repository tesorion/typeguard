# frozen_string_literal: true

module Yard
  module Resolution
    class Resolver
      include Yard::TypeModel::Definitions

      def initialize(definitions)
        @definitions = definitions
      end

      def resolve!
        @definitions.each do |definition|
          case definition
          when ModuleDefinition, ClassDefinition
            Object.const_get(definition.name.to_s, true)
            definition.members.each { |member| resolve_member(member) }
            # TODO: resolve nested modules/classes and ensure validation gets added
          when MethodDefinition
            resolve_member(definition)
          end
        end
      end

      def resolve_member(member)
        case member
        when MethodDefinition
          member.parameters.each { |param| param.types.each { |node| resolve_type(node) } }
          member.returns.types.each { |node| resolve_type(node) }
        end
      end

      # Raises a NameError if module names are not found
      # Maybe worth caching Object.const_get lookups
      def resolve_type(node)
        case node.shape
        when :basic
          node.metadata[:const] ||= Object.const_get(node.kind.to_s, true)
        when :generic, :fixed
          node.metadata[:const] ||= Object.const_get(node.kind.to_s, true)
          node.children.each { |child_node| resolve_type(child_node) }
        when :hash
          node.metadata[:const] ||= Object.const_get(node.kind.to_s, true)
          node.children.flatten.each { |child_node| resolve_type(child_node) }
        when :union
          node.children.each { |child_node| resolve_type(child_node) }
        when :literal
          # The parser has already rejected invalid literals,
        when :duck
          # Resolving duck-types at this point is unreliable
          # and slow, leaving it up to runtime checks
        when :untyped
          # Always correct
        else
          raise "Unknown node shape: #{node.shape}"
        end
      end
    end
  end
end
