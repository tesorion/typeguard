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
              Metrics.report_unexpected_return(sig, return_object, result, mod.name)
            end

            result
          end
        end
      end

      def self.validate_standard1(mod, method, sig, return_object, param0)
        mod.module_exec do
          define_method(sig.name) do |arg0, &blk|
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)

            result = method.bind_call(self, arg0, &blk)
            unless result.is_a?(return_object)
              Metrics.report_unexpected_return(sig, return_object, result, mod.name)
            end

            result
          end
        end
      end

      def self.validate_standard2(mod, method, sig, return_object, param0, param1)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, &blk|
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)
            Metrics.report_unexpected_argument(sig, param1, arg1, mod.name, 1) unless arg1.is_a?(param1)

            result = method.bind_call(self, arg0, arg1, &blk)
            unless result.is_a?(return_object)
              Metrics.report_unexpected_return(sig, return_object, result, mod.name)
            end

            result
          end
        end
      end

      def self.validate_standard3(mod, method, sig, return_object, param0, param1, param2)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, &blk|
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)
            Metrics.report_unexpected_argument(sig, param1, arg1, mod.name, 1) unless arg1.is_a?(param1)
            Metrics.report_unexpected_argument(sig, param2, arg2, mod.name, 2) unless arg2.is_a?(param2)

            result = method.bind_call(self, arg0, arg1, arg2, &blk)
            unless result.is_a?(return_object)
              Metrics.report_unexpected_return(sig, return_object, result, mod.name)
            end

            result
          end
        end
      end

      def self.validate_standard4(mod, method, sig, return_object, param0, param1, param2, param3)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, arg3, &blk|
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)
            Metrics.report_unexpected_argument(sig, param1, arg1, mod.name, 1) unless arg1.is_a?(param1)
            Metrics.report_unexpected_argument(sig, param2, arg2, mod.name, 2) unless arg2.is_a?(param2)
            Metrics.report_unexpected_argument(sig, param3, arg3, mod.name, 3) unless arg3.is_a?(param3)

            result = method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
            unless result.is_a?(return_object)
              Metrics.report_unexpected_return(sig, return_object, result, mod.name)
            end

            result
          end
        end
      end

      def self.validate_standard5(mod, method, sig, return_object, param0, param1, param2, param3, param4)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, arg3, arg4, &blk|
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)
            Metrics.report_unexpected_argument(sig, param1, arg1, mod.name, 1) unless arg1.is_a?(param1)
            Metrics.report_unexpected_argument(sig, param2, arg2, mod.name, 2) unless arg2.is_a?(param2)
            Metrics.report_unexpected_argument(sig, param3, arg3, mod.name, 3) unless arg3.is_a?(param3)
            Metrics.report_unexpected_argument(sig, param4, arg4, mod.name, 4) unless arg4.is_a?(param4)

            result = method.bind_call(self, arg0, arg1, arg2, arg3, arg4, &blk)
            unless result.is_a?(return_object)
              Metrics.report_unexpected_return(sig, return_object, result, mod.name)
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
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)

            method.bind_call(self, arg0, &blk)
          end
        end
      end

      def self.validate_fastest2(mod, method, sig, param0, param1)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, &blk|
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)
            Metrics.report_unexpected_argument(sig, param1, arg1, mod.name, 1) unless arg1.is_a?(param1)

            method.bind_call(self, arg0, arg1, &blk)
          end
        end
      end

      def self.validate_fastest3(mod, method, sig, param0, param1, param2)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, &blk|
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)
            Metrics.report_unexpected_argument(sig, param1, arg1, mod.name, 1) unless arg1.is_a?(param1)
            Metrics.report_unexpected_argument(sig, param2, arg2, mod.name, 2) unless arg2.is_a?(param2)

            method.bind_call(self, arg0, arg1, arg2, &blk)
          end
        end
      end

      def self.validate_fastest4(mod, method, sig, param0, param1, param2, param3)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, arg3, &blk|
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)
            Metrics.report_unexpected_argument(sig, param1, arg1, mod.name, 1) unless arg1.is_a?(param1)
            Metrics.report_unexpected_argument(sig, param2, arg2, mod.name, 2) unless arg2.is_a?(param2)
            Metrics.report_unexpected_argument(sig, param3, arg3, mod.name, 3) unless arg3.is_a?(param3)

            method.bind_call(self, arg0, arg1, arg2, arg3, &blk)
          end
        end
      end

      def self.validate_fastest5(mod, method, sig, param0, param1, param2, param3, param4)
        mod.module_exec do
          define_method(sig.name) do |arg0, arg1, arg2, arg3, arg4, &blk|
            Metrics.report_unexpected_argument(sig, param0, arg0, mod.name, 0) unless arg0.is_a?(param0)
            Metrics.report_unexpected_argument(sig, param1, arg1, mod.name, 1) unless arg1.is_a?(param1)
            Metrics.report_unexpected_argument(sig, param2, arg2, mod.name, 2) unless arg2.is_a?(param2)
            Metrics.report_unexpected_argument(sig, param3, arg3, mod.name, 3) unless arg3.is_a?(param3)
            Metrics.report_unexpected_argument(sig, param4, arg4, mod.name, 4) unless arg4.is_a?(param4)

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
              args.zip(param_validators).each_with_index do |(arg, param_validator), i|
                next if param_validator.valid?(arg)

                Metrics.report_unexpected_argument(sig, sig.parameters[i].types_string, arg, mod.name, i)
              end
              result = method.bind_call(self, *args, &blk)
              unless return_validator.valid?(result)
                Metrics.report_unexpected_return(sig, sig.returns.types_string, result, mod.name)

              end

              result
            end
          end
        else
          mod.module_exec do
            define_method(sig.name) do |*args, &blk|
              args.zip(param_validators).each_with_index do |(arg, param_validator), i|
                next if param_validator.valid?(arg)

                Metrics.report_unexpected_argument(sig, sig.parameters[i].types_string, arg, mod.name, i)
              end
              method.bind_call(self, *args, &blk)
            end
          end
        end
      end
    end
  end
end
