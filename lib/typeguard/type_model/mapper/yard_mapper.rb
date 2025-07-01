# frozen_string_literal: true

module Typeguard
  module TypeModel
    module Mapper
      # Maps YARD types to the type model
      class YardMapper
        include Typeguard::TypeModel::Definitions

        SPECIAL_LITERALS = %w[true false nil self void].freeze

        def self.parse_map(type)
          # NOTE: Using private YARD API here.
          map_yard(YARD::Tags::TypesExplainer::Parser.parse(type).first)
        end

        def self.map_yard(node)
          mapped_node = TypeNode.new(kind: node.name.to_sym, shape: :basic, children: [], metadata: {})
          case node
          when YARD::Tags::TypesExplainer::FixedCollectionType
            children = node.types.map { |child| map_yard(child) }
            mapped_node.shape = :fixed
            mapped_node.children = children
            mapped_node.metadata[:note] = 'Order-dependent lists must appear in the exact order'
          when YARD::Tags::TypesExplainer::CollectionType
            if node.name == 'Hash' && node.types.length == 2
              key_node = map_yard(node.types.first)
              value_node = map_yard(node.types.last)
              mapped_node.shape = :hash
              mapped_node.children = [[key_node], [value_node]]
              mapped_node.metadata[:note] = 'Hash specified via parametrized types: one key and one value type'
            else
              children = node.types.map { |child| map_yard(child) }
              mapped_node.shape = :generic
              mapped_node.children = children
              mapped_node.metadata[:note] = 'Generics specify one or more parametrized types'
            end
          when YARD::Tags::TypesExplainer::HashCollectionType
            key_nodes = node.key_types.map { |k| map_yard(k) }
            value_nodes = node.value_types.map { |v| map_yard(v) }
            mapped_node.shape = :hash
            mapped_node.children = [key_nodes, value_nodes]
            mapped_node.metadata[:note] = 'Hash specified via rocket syntax: multiple key and value type'
          when YARD::Tags::TypesExplainer::Type
            map_base(node, mapped_node)
          else raise "Unknown node type: #{node.class}"
          end
          mapped_node
        end

        def self.map_base(node, mapped_node)
          case node.name
          when *SPECIAL_LITERALS
            mapped_node.shape = :literal
            mapped_node.metadata = { note: 'Ruby (and YARD) supported literal' }
          when 'Boolean'
            true_node  = TypeNode.new(kind: :TrueClass, shape: :basic, children: [], metadata: {})
            false_node = TypeNode.new(kind: :FalseClass, shape: :basic, children: [], metadata: {})
            mapped_node.kind = :boolean
            mapped_node.shape = :union
            mapped_node.children = [true_node, false_node]
            mapped_node.metadata = { note: 'Boolean represents both TrueClass and FalseClass' }
          when /^#\w+/
            mapped_node.shape = :duck
            mapped_node.metadata = { note: "Duck-type: object should respond to :#{node.name[1..]}" }
          end
        end
      end
    end
  end
end
