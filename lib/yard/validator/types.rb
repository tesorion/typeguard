# frozen_string_literal: true

module Yard
  module Validation
    class Base
      def self.from(node)
        case node.shape
        when :basic
          Basic.new(node)
        when :generic
          Generic.new(node)
        when :fixed
          Fixed.new(node)
        when :hash
          GenericHash.new(node)
        when :union
          Union.new(node)
        when :literal
          case node.kind
          when :nil then Nil.new
          when :void, :self then Untyped.new
          else Literal.new(node)
          end
        when :duck
          Duck.new(node)
        when :untyped
          Untyped.new
        else
          raise "Unexpected type node shape: #{node.shape}"
        end
      end

      def valid?(_value)
        raise NotImplementedError, 'Abstract'
      end
    end

    class Basic < Base
      def initialize(node)
        @klass = node.metadata[:const]
      end

      def valid?(value)
        value.is_a?(@klass)
      end
    end

    class Generic < Base
      def initialize(node)
        @klass = node.metadata[:const]
        @children = node.children.map { |child| Base.from(child) }
      end

      def valid?(value)
        return false unless value.is_a?(@klass)

        value.all? do |element|
          @children.any? { |child| child.valid?(element) }
        end
      end
    end

    class Fixed < Base
      def initialize(node)
        @klass = node.metadata[:const]
        @children = node.children.map { |child| Base.from(child) }
      end

      def valid?(value)
        return false unless value.is_a?(@klass)
        return false unless value.size == @children.size

        @children.each_with_index.all? do |child, i|
          child.valid?(value[i])
        end
      end
    end

    class GenericHash < Base
      def initialize(node)
        @klass = node.metadata[:const]
        @keys   = node.children.first.map { |k| Base.from(k) }
        @values = node.children.last.map { |v| Base.from(v) }
      end

      def valid?(value)
        return false unless value.is_a?(@klass)

        value.all? do |k, v|
          key_valid = @keys.any? { |child| child.valid?(k) }
          value_valid = @values.any? { |child| child.valid?(v) }
          key_valid && value_valid
        end
      end
    end

    class Union < Base
      def initialize(node)
        @children = node.children.map { |child| Base.from(child) }
      end

      def valid?(value)
        @children.any? { |child| child.valid?(value) }
      end
    end

    class Literal < Base
      def initialize(node)
        @expected = node.kind.to_s
      end

      def valid?(value)
        value.to_s == @expected
      end
    end

    class Nil < Base
      def valid?(value)
        value.nil?
      end
    end

    class Duck < Base
      def initialize(node)
        @name = node.kind[1..]
      end

      def valid?(value)
        value.respond_to?(@name)
      end
    end

    class Untyped < Base
      def valid?(_)
        true
      end
    end

    class UnionOf < Base
      def initialize(children)
        @children = children
      end

      def valid?(value)
        @children.any? { |v| v.valid?(value) }
      end
    end
  end
end
