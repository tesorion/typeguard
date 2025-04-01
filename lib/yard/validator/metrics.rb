# frozen_string_literal: true

module Yard
  module Metrics
    Log = Struct.new(:module, :definition, :type, :error, :message, :source)

    @logs = []

    def self.flush
      puts "\nyard-validation errors: #{@logs.length} #{"\n" unless @logs.empty?}"
      @logs.each { |log| puts log.message }
    end

    def self.report(mod, definition, error, message)
      module_name = mod.name.to_sym
      type = definition.class.name.split('::').last.to_sym
      source = definition.source
      full_message = "#{error.upcase} #{type} (#{module_name}##{definition.name} in #{source}): #{message}"
      @logs << Log.new(module_name, definition.name, type, error, full_message, source)
      full_message
      # caller_location
    end

    def self.report_unexpected_return(sig, return_object, result, mod_name)
      caller = caller_locations(2, 1).first
      caller_string = "#{caller.path}:#{caller.lineno}"
      name = sig.name
      source = sig.returns.source
      msg = "Expected #{return_object} but received #{result.class} (#{result}) " \
      'from return statement ' \
      "in method '#{mod_name}##{name}' defined in #{source} and " \
      "called from #{caller_string}"
      @logs << Log.new(mod_name, sig.name, :ReturnDefinition, :unexpected_return, msg, source)
      raise TypeError, msg if Yard.config.validation.raise_on_unexpected_return
    end

    # raise TypeError, "Argument 0 type mismatch: expected #{param0}, got #{arg0.class}" unless arg0.is_a?(param0)

    def self.report_unexpected_argument(sig, expected, actual, mod_name, param_index)
      caller = caller_locations(2, 1).first
      caller_string = "#{caller.path}:#{caller.lineno}"
      parameter = sig.parameters[param_index]
      method_name = sig.name
      parameter_name = parameter.name
      source = parameter.source
      msg = "Expected #{expected} but received #{actual.class} (#{actual}) " \
      "for parameter '#{parameter_name}' " \
      "in method '#{mod_name}##{method_name}' defined in #{source} and " \
      "called from #{caller_string}"
      @logs << Log.new(mod_name, method_name, :ParameterDefinition, :unexpected_argument, msg, source)
      raise TypeError, msg if Yard.config.validation.raise_on_unexpected_argument
    end
  end
end
