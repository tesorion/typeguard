# frozen_string_literal: true

require 'rbs'

module Yard
  module TypeModel
    module Builder
      # Takes RBS signatures and returns a generic type model
      class RBSBuilder
        #  ruby -e "require 'rbs';loader=RBS::EnvironmentLoader.new(core_root: nil);loader.add(path:Pathname('sig'));environment=RBS::Environment.from_loader(loader);environment.declarations.each{|cls,entries|pp cls;pp entries}"
        # https://github.com/ruby/rbs/blob/master/docs/architecture.md
        # RBS files
        #   ↓         -- RBS::Parser
        # Syntax tree
        #   ↓
        # Environment
        #   ↓        -- Definition builder
        # Definition
        #
        # RBS::Parser.parse_method_type parsers a method type. ([T] (String) { (IO) -> T } -> Array[T])
        # RBS::Parser.parse_type parses a type. (Hash[Symbol, untyped])
        # RBS::Parser.parse_signature parses the whole RBS file.
        # @return [Yard::Initializer::RBSInitalizer] initializer for RBS signatures
        def initialize(target, _reparse)
          rbs_loader = RBS::EnvironmentLoader.new(core_root: nil)
          rbs_loader.add(path: Pathname(target))
          @rbs_env = RBS::Environment.from_loader(rbs_loader)
        end

        def build
          false
        end
      end
    end
  end
end
