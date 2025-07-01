# frozen_string_literal: true

module Typeguard
  module Metrics
    Log = Struct.new(:module, :definition, :type, :error, :expected, :actual, :source, :caller, keyword_init: true)

    @raise_on_unexpected_argument = false
    @raise_on_unexpected_return = false
    @db = nil
    @logs = []

    def self.config(validation)
      @raise_on_unexpected_argument = validation.raise_on_unexpected_argument
      @raise_on_unexpected_return = validation.raise_on_unexpected_return
    end

    def self.format_log(log)
      <<~MESSAGE
        - #{log.error.upcase} - Expected #{log.expected} for #{log.type} but received incompatible \
        #{log.actual} in '#{log.module}##{log.definition}' defined in #{log.source} \
        and called from #{log.caller}
      MESSAGE
    end

    def self.flush
      new_line = "\n" unless @logs.empty?
      puts "\ntypeguard errors [start]: #{@logs.length} #{new_line}\n"
      @logs.each { |log| puts format_log(log) }
      puts "\ntypeguard errors [end]: #{@logs.length} #{new_line}"
      if @db
        upload_logs
        insertions = @db.total_changes
        puts "\ntypeguard db insertions: #{insertions} #{new_line}"
      end
      @logs.clear
    end

    def self.report(mod, definition, error, expected, actual)
      caller = caller_locations(1, 1).first
      caller_string = caller.label.split('::').last
      module_name = mod.name.to_sym
      type = definition.class.name.split('::').last.gsub('Definition', '').to_sym
      source = definition.source
      log = Log.new(module: module_name, definition: definition.name, type: type, error: error,
                    expected: expected, actual: actual, source: source,
                    caller: caller_string)
      @logs << log
      log
    end

    def self.report_unexpected_return(sig, return_object, result, mod_name)
      caller = caller_locations(2, 1).first
      caller_string = "#{caller.path}:#{caller.lineno}"
      source = sig.returns.source
      log = Log.new(module: mod_name, definition: sig.name, type: :Return,
                    error: :unexpected_return, source: source, caller: caller_string,
                    expected: return_object, actual: result.class.to_s)
      @logs << log
      raise TypeError, format_log(log) if @raise_on_unexpected_return

      log
    end

    def self.report_unexpected_argument(sig, expected, actual, mod_name, parameter)
      caller = caller_locations(4, 1).first
      caller_string = "#{caller.path}:#{caller.lineno}"
      method_name = sig.name
      parameter_name = parameter.name
      source = parameter.source
      log = Log.new(module: mod_name, definition: method_name, type: parameter_name,
                    error: :unexpected_argument, source: source, caller: caller_string,
                    expected: expected, actual: actual.class.to_s)
      @logs << log
      raise TypeError, format_log(log) if @raise_on_unexpected_argument

      log
    end
  end
end
