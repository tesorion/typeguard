# frozen_string_literal: true

module Yard::Wrapper
  class PrependWrapper
    # @param [Hash<String, Hash<String, Hash>>] typed_modules simplified registry
    # @return [Yard::Wrapper::PrependWrapper]
    def initialize(typed_modules)
      @typed_modules = typed_modules
    end

    # @return [void]
    def wrap_all
      @typed_modules.each do |mod, methods|
        wrapper = Module.new
        methods.each do |method_name, type_info|
          visibility =
            if mod.private_method_defined?(method_name)
              :private
            elsif mod.protected_method_defined?(method_name)
              :protected
            else
              nil # Infer :public
            end
          validator = create_validator(method_name, **type_info)
          validator.module_eval { send(visibility, method_name) } if visibility
          wrapper.prepend(validator)
          puts <<~HEREDOC
            Wrapping method in #{mod}:
              name    = #{method_name}
              params  = #{type_info[:params]}
              returns = #{type_info[:returns]}
          HEREDOC
        end
        mod.prepend(wrapper)
      end
    end

    # TODO: replace prepend approach with define_method&method_added
    def create_validator(method_name, params:, returns:)
      Module.new do
        # @param [Object] arg Method argument to type validate
        # @param [Yard::Initializer::TypeNode] type_node Types to validate against
        # @return [Boolean] true if correct type, false if mismatched
        def validate_call(arg, type_node)
          return true if type_node == :void
          return false unless arg.is_a?(type_node.root)
          return true if type_node.children.empty?

          # return false unless arg.respond_to?(:each)
          if type_node.root == Array
            if type_node.children.size == 1
              return arg.all? do |element|
                validate_call(element, type_node.children.first)
              end
            end

            return arg.all? do |element|
              type_node.children.any? { |sub_type| validate_call(element, sub_type) }
            end

          end
          false
        end

        define_method(method_name) do |*args, **kwargs, &block|
          params.each_with_index do |param, i|
            expected = param[:types]
            arg = args[i]
            unless expected.any? { |type_node| validate_call(arg, type_node) }
              raise TypeError,
                    "Incorrect type for #{param[:name]}: received #{arg.class} but expected #{expected.map(&:to_s).join(',')}"
            end
          end
          result = super(*args, **kwargs, &block)
          return result if returns.include?(:void)

          unless returns.any? { |type_node| validate_call(result, type_node) }
            raise TypeError,
                  "Incorrect return type: received #{result.class} but expected #{returns.map(&:to_s).join(',')}"
          end

          result
        end
      end
    end
  end
end
