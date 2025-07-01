# frozen_string_literal: true

require 'dry-configurable'

module Typeguard
  extend Dry::Configurable

  SUPPORTED_SOURCES = %i[yard rbs].freeze

  def self.setting_bool(target = self, name, default: false)
    target.setting name, default: default, reader: true, constructor: proc { |value|
      raise "Config '#{name}' must be true or false" unless value.is_a?(TrueClass) || value.is_a?(FalseClass)

      value
    }
  end

  setting_bool :enabled
  setting_bool :reparse
  setting_bool :at_exit_report

  setting :target, reader: true
  setting :source, default: :yard, reader: true, constructor: proc { |value|
    raise "Config source must be one of #{SUPPORTED_SOURCES}" unless SUPPORTED_SOURCES.include?(value)

    value
  }

  setting :resolution, reader: true do
    Typeguard.setting_bool self, :raise_on_name_error
  end

  setting :wrapping, reader: true do
    Typeguard.setting_bool self, :raise_on_unexpected_arity
    Typeguard.setting_bool self, :raise_on_unexpected_visibility
  end

  setting :validation, reader: true do
    Typeguard.setting_bool self, :raise_on_unexpected_argument
    Typeguard.setting_bool self, :raise_on_unexpected_return
  end

  setting :sqlite3, reader: true

  def self.process!
    unless config.enabled
      puts 'WARNING: typeguard disabled'
      return
    end

    Typeguard::Metrics.config(config.validation, config.sqlite3)
    Typeguard::TypeModel::Builder.send(config.source)
    builder = TypeModel::Builder::IMPLEMENTATION.new(config.target, config.reparse)
    definitions = builder.build
    Typeguard::Resolution::Resolver.new(definitions, config.resolution).resolve!
    Typeguard::Validation::Wrapper.new(definitions, config.wrapping).wrap!
    at_exit { Typeguard::Metrics.flush } if config.at_exit_report
  end
end
