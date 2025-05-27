# frozen_string_literal: true

module Yard
  module Validation
    class Validator
      def self.param_validator(types)
        children = types.map { |node| Base.from(node) }
        if children.size == 1
          children.first
        else
          UnionOf.new(children)
        end
      end

      def self.zip_params(method_params, sig_params)
        method_params.map do |mp|
          sig_param = sig_params.find { |sp| sp.name.to_s.gsub(/[*:]/, '').to_sym == mp.last }
          validator = param_validator(sig_param.types) if sig_param
          [mp, sig_param, validator]
        end
      end

      def self.param_names(zipped_params)
        # Tuples of [parameter, invocation] names
        zipped_params.map do |(type, name), sp, _|
          name = name.to_s
          case type
          when :req     then [name, name]                                         # foo
          when :keyreq  then ["#{name}:", "#{name}: #{name}"]                     # foo:
          when :keyrest then [name == '**' ? name : "**#{name}"] * 2              # **foo
          when :rest    then [name == '*' ? name : "*#{name}"] * 2                # *foo
          when :block   then [name == '&' ? name : "&#{name}"] * 2                # &foo
          when :opt     then ["#{name} = (#{sp.default})", name]                  # foo = (bar)
          when :key     then ["#{name}: (#{sp.default})", "#{name}: #{name}"]     # foo: (bar)
          else raise type
          end
        end
      end

      def self.exhaustive_path(mod, method, sig)
        zipped_params = zip_params(method.parameters, sig.parameters)
        return_validator = (param_validator(sig.returns.types) if sig.returns && !sig.returns.types.empty?)
        p_names = param_names(zipped_params)
        block_params = p_names.map(&:first).join(', ')
        call_args = p_names.map(&:last).reject { |s| ['*', '**', '&'].include?(s) }
        call_args = call_args.join(', ')
        locals = method.parameters.map { |s| ['*', '**', '&'].include?(s.last.to_s) ? nil : s.last }
        locals = locals.compact.join(', ')
        redefinition = sig.scope == :class ? 'define_singleton_method' : 'define_method'
        if return_validator
          mod.module_eval <<~RUBY, __FILE__, __LINE__ + 1
            #{redefinition}(sig.name) do |#{block_params}|
              zipped_params.zip([#{locals}]).each do |(mp, sp, validator), local|
                next if validator.nil? || validator.valid?(local)

                Metrics.report_unexpected_argument(sig, sp.types_string, local, mod.name, sp)
              end
              result = method.bind_call(self, #{call_args})
              unless return_validator.valid?(result)
                Metrics.report_unexpected_return(sig, sig.returns.types_string, result, mod.name)
              end
              result
            end
          RUBY
        else
          mod.module_eval <<~RUBY, __FILE__, __LINE__ + 1
            #{redefinition}(sig.name) do |#{block_params}|
              zipped_params.zip([#{locals}]).each do |(mp, sp, validator), local|
                next if validator.nil? || validator.valid?(local)

                Metrics.report_unexpected_argument(sig, sp.types_string, local, mod.name, sp)
              end
              method.bind_call(self, #{call_args})
            end
          RUBY
        end
      end
    end
  end
end
