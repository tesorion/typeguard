# frozen_string_literal: true

module Yard
  module Validation
    class Wrapper
      include Yard::TypeModel::Definitions

      def initialize(definitions, config)
        @definitions = definitions
        @config = config
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
        return if unsafe_method?(sig)

        target = sig.scope == :class ? mod.singleton_class : mod
        method_name = sig.name
        original_method = target.instance_method(method_name)
        check_arity(mod, sig, original_method)
        actual_visibility = check_visibility(target, mod, sig, method_name)
        Validator.exhaustive_path(mod, original_method, sig)
        target.send(actual_visibility, method_name)
      end

      def unsafe_method?(sig)
        # It is unsafe to redefine these methods because
        # the return type is not always the same: assignment
        # vs method call
        sig.name == :initialize || sig.name.to_s =~ /=$/
      end

      def check_arity(mod, sig, original_method)
        expected_arity = sig.parameters.size
        actual_arity = original_method.parameters.count
        return if expected_arity == actual_arity

        log = Metrics.report(mod, sig, :unexpected_arity, expected_arity, actual_arity)
        raise Metrics.format_log(log) if @config.raise_on_unexpected_arity
      end

      def check_visibility(target, mod, sig, method_name)
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

        error = false
        unless expected_visibility == actual_visibility
          if expected_visibility == :public && actual_visibility == :private
            if sig.name == :initialize
              # Initialize is private by default, ignore
            elsif mod == Object
              # Methods on Object (root) are private by default, ignore
            else
              error = true
            end
          else
            error = true
          end
        end

        if error
          log = Metrics.report(mod, sig, :unexpected_visibility, expected_visibility, actual_visibility)
          raise Metrics.format_log(log) if @config.raise_on_unexpected_visibility
        end

        actual_visibility
      end
    end
  end
end
