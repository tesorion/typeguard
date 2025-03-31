# frozen_string_literal: true

# TODO: replace parser with YARD::Tags::TypesExplainer::Parser.parse

module Yard
  module TypeModel
    module Parser
      class YardParser
        include Yard::TypeModel::Definitions
        require 'strscan'

        NAME_PATTERN     = /#\w+|(?:\w+(?:::\w+)*)|nil|true|false|self|void|Boolean/.freeze
        SPECIAL_LITERALS = %w[true false nil self void].freeze

        # Parse a non-union string into a TypeNode
        def self.parse(string)
          scanner = StringScanner.new(string)
          node = parse_type(scanner)
          skip_whitespace(scanner)
          raise SyntaxError, "Unexpected input remaining: #{scanner.rest}" unless scanner.eos?

          node
        end

        def self.parse_type(s)
          skip_whitespace(s)
          name = case s.peek(1)
                 when '<', '(' then 'Array'
                 when '{' then 'Hash'
                 else
                   token = s.scan(NAME_PATTERN)
                   raise SyntaxError, "Expected type name at pos #{s.pos}" unless token

                   token
                 end

          if (special_node = parse_special(name))
            return special_node
          end

          node = TypeNode.new(kind: name.to_sym, shape: :basic, children: [], metadata: {})
          skip_whitespace(s)
          case s.peek(1)
          when '<'
            s.getch
            children = parse_list(s, ',')
            skip_whitespace(s)
            raise SyntaxError, "Expected '>' at pos #{s.pos}" unless s.getch == '>'

            if node.kind == :Hash
              raise SyntaxError, 'Hash generic syntax must have exactly 2 parameters' unless children.size == 2

              node.shape    = :hash
              node.children = [[children[0]], [children[1]]]
              node.metadata[:note] = 'Hash specified via parametrized types: one key and one value type'
            else
              node.shape    = :generic
              node.children = children
              node.metadata[:note] = 'Generics specify one or more parametrized types'
            end
          when '('
            s.getch
            children = parse_list(s, ',')
            skip_whitespace(s)
            raise SyntaxError, "Expected ')' at pos #{s.pos}" unless s.getch == ')'

            node.shape    = :fixed
            node.children = children
            node.metadata[:note] = 'Order-dependent lists must appear in the exact order'
          when '{'
            s.getch
            key_types = parse_list(s, ',')
            skip_whitespace(s)
            raise SyntaxError, "Expected '=>' at pos #{s.pos}" unless s.scan(/=>/)

            skip_whitespace(s)
            value_types = parse_list(s, ',')
            skip_whitespace(s)
            raise SyntaxError, "Expected '}' at pos #{s.pos}" unless s.getch == '}'

            node.shape    = :hash
            node.children = [key_types, value_types]
            node.metadata[:note] = 'Hash specified with => syntax: multiple key/value types'
          end

          node
        end

        def self.parse_special(name)
          case name
          when *SPECIAL_LITERALS
            TypeNode.new(
              kind: name.to_sym,
              shape: :literal,
              children: [],
              metadata: { note: 'Ruby (and YARD) supported literal' }
            )
          when 'Boolean'
            true_node  = TypeNode.new(kind: :TrueClass, shape: :basic, children: [], metadata: {})
            false_node = TypeNode.new(kind: :FalseClass, shape: :basic, children: [], metadata: {})
            TypeNode.new(
              kind: :boolean,
              shape: :union,
              children: [true_node, false_node],
              metadata: { note: 'Boolean represents both TrueClass and FalseClass' }
            )
          else
            return unless name.start_with?('#')

            TypeNode.new(
              kind: name.to_sym,
              shape: :duck,
              children: [],
              metadata: { note: "Duck-type: object should respond to :#{name[1..]}" }
            )
          end
        end

        def self.parse_list(s, delimiter)
          items = []
          loop do
            skip_whitespace(s)
            items << parse_type(s)
            skip_whitespace(s)
            break unless s.peek(1) == delimiter

            s.getch
          end
          items
        end

        def self.skip_whitespace(s)
          s.skip(/\s+/)
        end
      end
    end
  end
end
