# frozen_string_literal: true

module Yard
  module Metrics
    Log = Struct.new(:module, :definition, :type, :error, :message, :source)

    @raise_on_unexpected_argument = false
    @raise_on_unexpected_return = false
    @logs = []

    def self.config(validation)
      @raise_on_unexpected_argument = validation.raise_on_unexpected_argument
      @raise_on_unexpected_return = validation.raise_on_unexpected_return
    end

    def self.flush
      new_line = "\n" unless @logs.empty?
      puts "\nyard-validation errors [start]: #{@logs.length} #{new_line}\n"
      @logs.each { |log| puts "- #{log.message}" }
      puts "\nyard-validation errors [end]: #{@logs.length} #{new_line}"
    end

    def self.report(mod, definition, error, message)
      module_name = mod.name.to_sym
      type = definition.class.name.split('::').last.to_sym
      source = definition.source
      full_message = "#{error.upcase} #{type} (#{module_name}##{definition.name} in #{source}): #{message}"
      @logs << Log.new(module_name, definition.name, type, error, full_message, source)
      full_message
    end

    def self.report_unexpected_return(sig, return_object, result, mod_name)
      caller = caller_locations(2, 1).first
      caller_string = "#{caller.path}:#{caller.lineno}"
      name = sig.name
      source = sig.returns.source
      msg = "UNEXPECTED_RETURN Expected #{return_object} but received incompatible #{result.class} " \
      'from return statement ' \
      "in method '#{mod_name}##{name}' defined in #{source} and " \
      "called from #{caller_string}"
      @logs << Log.new(mod_name, sig.name, :ReturnDefinition, :unexpected_return, msg, source)
      raise TypeError, msg if @raise_on_unexpected_return
    end

    def self.report_unexpected_argument(sig, expected, actual, mod_name, parameter)
      caller = caller_locations(4, 1).first
      caller_string = "#{caller.path}:#{caller.lineno}"
      method_name = sig.name
      parameter_name = parameter.name
      source = parameter.source
      msg = "UNEXPECTED_ARGUMENT Expected #{expected} but received incompatible #{actual.class} " \
      "for parameter '#{parameter_name}' " \
      "in method '#{mod_name}##{method_name}' defined in #{source} and " \
      "called from #{caller_string}"
      @logs << Log.new(mod_name, method_name, :ParameterDefinition, :unexpected_argument, msg, source)
      raise TypeError, msg if @raise_on_unexpected_argument
    end
  end
end
