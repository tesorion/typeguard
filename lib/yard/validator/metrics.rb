# frozen_string_literal: true

module Yard
  module Metrics
    # TODO: send logs
    @registry = {}

    def self.flush
      @registry.each do |klass, method_counters|
        method_counters.each do |method_name, counter|
          puts "#{klass}##{method_name}: #{counter.value} errors"
          counter.reset!
        end
      end
    end

    def self.report(klass, method_name)
      @registry[klass] ||= {}
      @registry[klass][method_name] ||= Counter.new
      @registry[klass][method_name].increment
    end

    class Counter
      attr_reader :value

      def initialize
        @value = 0
      end

      def increment
        @value += 1
      end

      def reset!
        @value = 0
      end
    end
  end
end
