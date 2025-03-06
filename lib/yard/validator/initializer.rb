# frozen_string_literal: true

module Yard::Initializer
  class YardocInitializer
    require 'yard'

    # @param  [String] target .yardoc file
    # @return [Yard::Initializer::YardocInitializer] initializer for YARD comments
    def initialize(target)
      YARD::Registry.load!(target)
    end

    # @return [Hash<String, Hash<String, Hash>>] types for all modules
    def resolve_types
      YARD::Registry.all(:method).each_with_object({}) do |method, hash|
        raise "No type info found: #{method}" unless method.tag(:param) || method.tag(:return)

        mod_name = method.namespace.to_s
        raise "Non-namespace not supported: #{method}" if mod_name.empty?

        mod = Object.const_get(mod_name)
        hash[mod] ||= {}
        hash[mod][method.name] = {
          params: method.tags(:param).map do |t|
            { name: t.name, types: t.types.map { |type_str| resolve_type(type_str) } }
          end,
          returns: (method.tag(:return)&.types || []).map { |type_str| resolve_type(type_str) }
        }
        puts <<~HEREDOC
          Added method to cache:
            path   = #{method.path}
            object = #{mod_name}
        HEREDOC
      end
    end

    # @param [String] type YARD string
    # @return [Yard::Initializer::TypeNode] root type node
    def resolve_type(type)
      return :void if type == 'void' # Handle void return type

      raise "Invalid type format: #{type}" unless type =~ /^([A-Z]\w*)(?:<(.+)>)?$/

      root_str = Regexp.last_match(1)
      root = begin
        Kernel.const_get(root_str)
      rescue StandardError
        nil
      end
      raise "Undefined constant found: #{root_str}" if root.nil?

      children = Regexp.last_match(2)&.split(/\s*,\s*/)&.map { |s| resolve_type(s) } || []
      TypeNode.new(root, children)
    end
  end

  class RBSInitalizer
    # @return [Yard::Initializer::RBSInitalizer] initializer for RBS signatures
    def initialize
      raise NotImplementedError
    end
  end

  class TypeNode
    attr_reader :root, :children

    # @param [Object] root Object root type
    # @param [Array<Yard::Initializer::TypeNode>] children Type nodes in this collection
    # @return [Yard::Initializer::TypeNode] a type node
    def initialize(root, children = [])
      @root = root
      @children = children
    end

    # @return [String] string of root and children
    def to_s
      root_str = root.respond_to?(:name) ? root.name : root.to_s
      if children.empty?
        root_str
      else
        "#{root_str}<#{children.map(&:to_s).join(', ')}>"
      end
    end

    # @return [String] this object to string
    def inspect
      to_s
    end
  end
end
