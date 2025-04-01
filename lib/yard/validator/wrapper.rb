# frozen_string_literal: true

module Yard
  module Validation
    class Wrapper
      include Yard::TypeModel::Definitions

      def initialize(definitions)
        @definitions = definitions
      end

      def wrap!
        @definitions.each { |definition| wrap_definition(definition) }
      end

      def wrap_definition(definition)
        case definition
        when ModuleDefinition, ClassDefinition
          mod = Object.const_get(definition.name)
          definition.children.each do |child|
            if child.is_a?(MethodDefinition)
              wrap_method(mod, child)
            else
              # Wrap nested modules
              wrap_definition(child)
            end
          end
        when MethodDefinition
          # Method defined in root, as a private instance method of Object
          wrap_method(Object, definition)
        else raise "Unexpected definition for '#{definition}'"
        end
      end

      def wrap_method(mod, sig)
        target = sig.scope == :class ? mod.singleton_class : mod
        # use sym name instead of string?
        method_name = sig.name
        original_method = target.instance_method(method_name)
        expected_arity = sig.parameters.size
        actual_arity = original_method.parameters.count
        unless expected_arity == actual_arity
          # TODO: check/raise if configured
          raise "Expected arity of '#{expected_arity}' but received '#{actual_arity}'.\n" \
                "Module: #{mod}\n" \
                "Sig: #{sig.name}\n"
        end
        expected_visibility = sig.visibility
        actual_visibility =
          if target.public_instance_methods(false).include?(method_name)
            :public
          elsif target.protected_instance_methods(false).include?(method_name)
            :protected
          elsif target.private_instance_methods(false).include?(method_name)
            :private
          else
            :public
          end
        unless expected_visibility == actual_visibility
          if expected_visibility == :public && actual_visibility == :private
            if sig.name == :initialize
              # Initialize is private by default, ignore
            elsif mod == Object
              # Methods on Object (root) are private by default, ignore
            else
              # TODO: check/raise if configured
              raise "Expected visibility of public but received private.\n" \
              "Module: #{mod}\n" \
              "Sig: #{sig.name}\n"
            end
          else
            # TODO: check/raise if configured
            raise "Expected visibility of '#{expected_visibility}' but received '#{actual_visibility}'.\n" \
            "Module: #{mod}\n" \
            "Sig: #{sig.name}\n"
          end
        end
        define_wrapper(mod, original_method, sig)
        target.send(actual_visibility, method_name)
      end

      def define_wrapper(mod, method, sig)
        required_params = method.parameters.all? { |type, _| type == :req } && sig.parameters.size <= 5
        simple_params = required_params && sig.parameters.all? do |param|
          param.types.size == 1 && param.types.first.shape == :basic
        end
        simple_return = sig.returns.types.size == 1 && sig.returns.types.first.shape == :basic
        any_return = sig.returns.types.all? do |type|
          type.shape == :untyped || %i[void self].include?(type.kind)
        end
        if simple_params && simple_return
          Validator.standard_path(mod, method, sig)
        elsif simple_params && any_return
          Validator.fastest_path(mod, method, sig)
        else
          Validator.exhaustive_path(mod, method, sig)
        end
        # TODO: move
        current = mod.instance_method(sig.name)
        mod.define_method(sig.name) do |*args, &blk|
          current.bind_call(self, *args, &blk)
        rescue TypeError => _e
          # Yard::Metrics.report(mod, sig.name, :err, e)
        end
      end
    end
  end
end
