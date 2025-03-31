# frozen_string_literal: true

module Yard
  module TypeModel
    module Builder
      IMPL_SYM = :IMPLEMENTATION

      def self.yard
        require_relative 'builder/yard_builder'
        require_relative 'mapper/yard_mapper'
        const_set(IMPL_SYM, YardBuilder) unless const_defined?(IMPL_SYM)
      end

      def self.rbs
        require_relative 'builder/rbs_builder'
        require_relative 'mapper/rbs_mapper'
        const_set(IMPL_SYM, RBSBuilder) unless const_defined?(IMPL_SYM)
      end
    end
  end
end
