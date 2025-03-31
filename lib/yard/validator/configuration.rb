# frozen_string_literal: true

require 'dry-configurable'

module Yard
  extend Dry::Configurable

  SUPPORTED_SOURCES = %i[yard rbs].freeze

  setting :enabled, default: false

  setting :source, default: :yard, reader: true, constructor: proc { |value|
    raise "Config source must be one of #{SUPPORTED_SOURCES}" unless SUPPORTED_SOURCES.include?(value)

    value
  }
  setting :target, reader: true

  setting :reparse, default: false, reader: true, constructor: proc { |value|
    raise 'Config reparse must be true or false' unless value.is_a?(TrueClass) || value.is_a?(FalseClass)

    value
  }

  setting :at_exit_report, default: false, constructor: proc { |value|
    raise 'Config at_exit_report must be true or false' unless value.is_a?(TrueClass) || value.is_a?(FalseClass)

    value
  }

  # TODO: implement flags below
  setting :raise_on_failure, default: true
  setting :report_on_failure, default: true
  setting :document_untyped, default: true
  setting :report_untyped, default: true

  def self.process!
    unless config.enabled
      puts 'WARNING: yard-validator disabled'
      return
    end

    builder = Yard::TypeModel::Builder.send(config.source)
    definitions = builder.new(config.target, config.reparse).build
    Yard::Resolution::Resolver.new(definitions).resolve!
    Yard::Validation::Wrapper.new(definitions).wrap!

    at_exit { Yard::Metrics.flush } if config.at_exit_report
  end
end
