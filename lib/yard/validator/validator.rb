# frozen_string_literal: true

module Yard
  module Validation
    class Validator
      def self.standard_path(mod, method, sig)
        sig_params = sig.parameters.map { |param| param.types.first.metadata[:const] }
        return_object = sig.returns.types.first.metadata[:const]
        case sig.parameters.size
        when 0 then validate_standard0(mod, method, sig, return_object)
        when 1 then validate_standard1(mod, method, sig, return_object, sig_params[0])
        when 2 then validate_standard2(mod, method, sig, return_object, sig_params[0], sig_params[1])
        when 3 then validate_standard3(mod, method, sig, return_object, sig_params[0], sig_params[1], sig_params[2])
        when 4 then validate_standard4(mod, method, sig, return_object, sig_params[0], sig_params[1], sig_params[2],
                                       sig_params[3])
        when 5 then validate_standard5(mod, method, sig, return_object, sig_params[0], sig_params[1], sig_params[2],
                                       sig_params[3], sig_params[4])
        end
      end

      def self.validate_standard0(mod, method, sig, return_object)
        mod.module_exec do
          define_method(sig.name) do |&blk|
            result = method.bind_call(self, &blk)
            unless result.is_a?(return_object)
              raise TypeError, "Return type mismatch: expected #{return_object}, got #{result.class}"
            end

            result
          end
        end
      end

      def self.validate_standard1(mod, method, sig, return_object, param0)
        mod.module_exec do
          define_method(sig.name) do |arg0, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)

            result = method.bind_call(self, arg0, &blk)
            unless result.is_a?(return_object)
              raise TypeError, "Return type mismatch: expected #{return_object}, got #{result.class}"
            end

            result
          end
        end
      end

      def self.validate_standard2(mod, method, sig, return_object, param0, param1)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)
            raise TypeError, "Argument 1 type mismatch: expected #{param1}, got #{arg1.class}" unless arg1.is_a?(param1)

            result = method.bind_call(self, arg0, arg1, &blk)
            unless result.is_a?(return_object)
              raise TypeError, "Return type mismatch: expected #{return_object}, got #{result.class}"
            end

            result
          end
        end
      end

      def self.validate_standard3(mod, method, sig, return_object, param0, param1, param2)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)
            raise TypeError, "Argument 1 type mismatch: expected #{param1}, got #{arg1.class}" unless arg1.is_a?(param1)
            raise TypeError, "Argument 2 type mismatch: expected #{param2}, got #{arg2.class}" unless arg2.is_a?(param2)

            result = method.bind_call(self, arg0, arg1, arg2, &blk)
            unless result.is_a?(return_object)
              raise TypeError, "Return type mismatch: expected #{return_object}, got #{result.class}"
            end

            result
          end
        end
      end

      def self.validate_standard4(mod, method, sig, return_object, param0, param1, param2, param3)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, arg3, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)
            raise TypeError, "Argument 1 type mismatch: expected #{param1}, got #{arg1.class}" unless arg1.is_a?(param1)
            raise TypeError, "Argument 2 type mismatch: expected #{param2}, got #{arg2.class}" unless arg2.is_a?(param2)
            raise TypeError, "Argument 3 type mismatch: expected #{param3}, got #{arg3.class}" unless arg3.is_a?(param2)

            result = method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
            unless result.is_a?(return_object)
              raise TypeError, "Return type mismatch: expected #{return_object}, got #{result.class}"
            end

            result
          end
        end
      end

      def self.validate_standard5(mod, method, sig, return_object, param0, param1, param2, param3, param4)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, arg3, arg4, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)
            raise TypeError, "Argument 1 type mismatch: expected #{param1}, got #{arg1.class}" unless arg1.is_a?(param1)
            raise TypeError, "Argument 2 type mismatch: expected #{param2}, got #{arg2.class}" unless arg2.is_a?(param2)
            raise TypeError, "Argument 3 type mismatch: expected #{param3}, got #{arg3.class}" unless arg3.is_a?(param2)
            raise TypeError, "Argument 4 type mismatch: expected #{param4}, got #{arg4.class}" unless arg4.is_a?(param2)

            result = method.bind_call(self, arg0, arg1, arg2, arg3, arg4, &blk)
            unless result.is_a?(return_object)
              raise TypeError, "Return type mismatch: expected #{return_object}, got #{result.class}"
            end

            result
          end
        end
      end

      def self.fastest_path(mod, method, sig)
        sig_params = sig.parameters.map { |param| param.types.first.metadata[:const] }
        case sig.parameters.size
        when 0 then validate_fastest0(mod, method, sig)
        when 1 then validate_fastest1(mod, method, sig, sig_params[0])
        when 2 then validate_fastest2(mod, method, sig, sig_params[0], sig_params[1])
        when 3 then validate_fastest3(mod, method, sig, sig_params[0], sig_params[1], sig_params[2])
        when 4 then validate_fastest4(mod, method, sig, return_object, sig_params[0], sig_params[1], sig_params[2],
                                      sig_params[3])
        when 5 then validate_fastest5(mod, method, sig, return_object, sig_params[0], sig_params[1], sig_params[2],
                                      sig_params[3], sig_params[4])
        else
          raise "Unsupported arity for validate_fastest: #{sig.parameters.size}"
        end
      end

      def self.validate_fastest0(mod, method, sig)
        mod.module_exec do
          define_method(sig.name) do |&blk|
            method.bind_call(self, &blk)
          end
        end
      end

      def self.validate_fastest1(mod, method, sig, param0)
        mod.module_exec do
          define_method(sig.name) do |arg0, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)

            method.bind_call(self, arg0, &blk)
          end
        end
      end

      def self.validate_fastest2(mod, method, sig, param0, param1)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)
            raise TypeError, "Argument 1 type mismatch: expected #{param1}, got #{arg1.class}" unless arg1.is_a?(param1)

            method.bind_call(self, arg0, arg1, &blk)
          end
        end
      end

      def self.validate_fastest3(mod, method, sig, param0, param1, param2)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)
            raise TypeError, "Argument 1 type mismatch: expected #{param1}, got #{arg1.class}" unless arg1.is_a?(param1)
            raise TypeError, "Argument 2 type mismatch: expected #{param2}, got #{arg2.class}" unless arg2.is_a?(param2)

            method.bind_call(self, arg0, arg1, arg2, &blk)
          end
        end
      end

      def self.validate_fastest4(mod, method, sig, param0, param1, param2, param3)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, arg3, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)
            raise TypeError, "Argument 1 type mismatch: expected #{param1}, got #{arg1.class}" unless arg1.is_a?(param1)
            raise TypeError, "Argument 2 type mismatch: expected #{param2}, got #{arg2.class}" unless arg2.is_a?(param2)
            raise TypeError, "Argument 3 type mismatch: expected #{param3}, got #{arg3.class}" unless arg3.is_a?(param2)

            method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
          end
        end
      end

      def self.validate_fastest5(mod, method, sig, param0, param1, param2, param3, param4)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, arg3, arg4, &blk|
            raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)
            raise TypeError, "Argument 1 type mismatch: expected #{param1}, got #{arg1.class}" unless arg1.is_a?(param1)
            raise TypeError, "Argument 2 type mismatch: expected #{param2}, got #{arg2.class}" unless arg2.is_a?(param2)
            raise TypeError, "Argument 3 type mismatch: expected #{param3}, got #{arg3.class}" unless arg3.is_a?(param2)
            raise TypeError, "Argument 4 type mismatch: expected #{param4}, got #{arg4.class}" unless arg4.is_a?(param2)

            method.bind_call(self, arg0, arg1, arg2, arg3, arg4, &blk)
          end
        end
      end

      def self.param_validator(types)
        children = types.map { |node| Base.from(node) }
        if children.size == 1
          children.first
        else
          UnionOf.new(children)
        end
      end

      def self.exhaustive_path(mod, method, sig)
        param_validators = sig.parameters.map { |param| param_validator(param.types) }
        return_validator = (param_validator(sig.returns.types) if sig.returns && !sig.returns.types.empty?)
        if return_validator
          mod.module_exec do
            define_method(sig.name) do |*args, &blk|
              args.zip(param_validators).each do |arg, param_validator|
                unless param_validator.valid?(arg)
                  raise TypeError,
                        "Expected #{sig.parameters[idx].type_strings} but received: #{arg.inspect}"
                end
              end
              result = method.bind_call(self, *args, &blk)
              unless return_validator.valid?(result)
                raise TypeError,
                      "Expected #{sig.returns.type_strings} but received: #{result.inspect}"
              end

              result
            end
          end
        else
          mod.module_exec do
            define_method(sig.name) do |*args, &blk|
              args.zip(param_validators).each do |arg, param_validator|
                unless param_validator.valid?(arg)
                  raise TypeError,
                        "Expected #{sig.parameters[idx].type_strings} but received: #{arg.inspect}"
                end
              end
              method.bind_call(self, *args, &blk)
            end
          end
        end
      end
    end
  end
end
