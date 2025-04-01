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
  end
end
