# frozen_string_literal: true

require 'rbs'

module Yard
  module TypeModel
    module Mapper
      # Maps RBS types to the generic type model
      class RBSMapper
        include Yard::TypeModel::Definitions

        # @param type [RBS::Types::Base] an RBS type object
        # @return [TypeNode] a mapped type node in the generic model.
        def self.parse_map(type)
          map_rbs(type)
        end

        def self.map_rbs(node)
          name = (node.respond_to?(:name) ? node.name.relative!.to_s : node.to_s).to_sym
          mapped_node = TypeNode.new(kind: name, shape: :basic, children: [], metadata: {})

          case node
          when RBS::Types::ClassInstance
            if node.args.empty?
              mapped_node.shape = :basic
            elsif node.name.name == :Hash && node.args.length == 2
              key_node = map_rbs(node.args.first)
              value_node = map_rbs(node.args.last)
              mapped_node.shape = :hash
              mapped_node.children = [[key_node], [value_node]]
              mapped_node.metadata[:note] = 'Hash specified via parametrized types: one key and one value type'
            else
              children = node.args.map { |arg| map_rbs(arg) }
              mapped_node.children = children
              mapped_node.shape = :generic
            end
          when RBS::Types::Tuple
            children = node.types.map { |child| map_rbs(child) }
            mapped_node.kind = :Array
            mapped_node.shape = :fixed
            mapped_node.children = children
            mapped_node.metadata[:note] = 'Tuples are a fixed-length array with known types for each element'
          when RBS::Types::Union
            children = node.types.map { |child| map_rbs(child) }
            mapped_node.shape = :union
            mapped_node.children = children
            mapped_node.metadata[:note] = 'Union types denote a type of one of the given types'
          when RBS::Types::Optional
            child = map_rbs(node.type)
            nil_node = TypeNode.new(kind: :nil, shape: :literal, children: [], metadata: { note: 'Optional nil' })
            mapped_node.shape = :union
            mapped_node.children = [child, nil_node]
            mapped_node.metadata[:note] = 'Optional type'
          when RBS::Types::Bases::Bool
            true_node  = TypeNode.new(kind: :TrueClass, shape: :basic, children: [], metadata: {})
            false_node = TypeNode.new(kind: :FalseClass, shape: :basic, children: [], metadata: {})
            mapped_node.kind = :boolean
            mapped_node.shape = :union
            mapped_node.children = [true_node, false_node]
            mapped_node.metadata = { note: 'Boolean represents both TrueClass and FalseClass' }
          when RBS::Types::Bases::Any
            mapped_node.kind = :untyped
            mapped_node.shape = :untyped
            mapped_node.metadata[:note] = 'Type not specified: any'
          when RBS::Types::Bases::Self
            mapped_node.shape = :literal
            mapped_node.metadata[:note] = 'self indicates that calling this method on will return the same type as the type of the receiver'
          when RBS::Types::Bases::Void
            mapped_node.shape = :literal
            mapped_node.metadata[:note] = 'void is only allowed as a return type or a generic parameter'
          when RBS::Types::Bases::Nil
            mapped_node.shape = :literal
            mapped_node.metadata[:note] = 'nil is for nil. nil is recommended over NilClass'
          when RBS::Types::Literal
            mapped_node.shape = :literal
            mapped_node.metadata[:note] = 'Literal types denote a type with only one value of the literal'
          else raise "Unknown node type: #{node.class} #{node}"
          end
          mapped_node
        end
      end
    end
  end
end
