# frozen_string_literal: true

module Yard
  module TypeModel
    module Builder
      IMPL_SYM = :IMPLEMENTATION

      def self.yard
        require_relative 'builder/yard_builder'
        const_set(IMPL_SYM, YardBuilder) unless const_defined?(IMPL_SYM)
      end

      def self.rbs
        require_relative 'builder/rbs_builder'
        const_set(IMPL_SYM, RBSBuilder) unless const_defined?(IMPL_SYM)
      end
    end
  end
end
