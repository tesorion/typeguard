# frozen_string_literal: true

module Typeguard
  module TypeModel
    module Builder
      IMPL_SYM = :IMPLEMENTATION
      def self.yard
        require_relative 'builder/yard_builder'
        require_relative 'mapper/yard_mapper'
        const_set(IMPL_SYM, YardBuilder)
      end

      def self.rbs
        require_relative 'builder/rbs_builder'
        require_relative 'mapper/rbs_mapper'
        const_set(IMPL_SYM, RBSBuilder)
      end
    end
  end
end
