# frozen_string_literal: true

require 'rbs'

module Typeguard
  module TypeModel
    module Builder
      # Takes RBS signatures and returns a generic type model
      class RBSBuilder
        include Typeguard::TypeModel::Definitions

        attr_reader :rbs_env

        # @return [Typeguard::Initializer::RBSInitalizer] initializer for RBS signatures
        def initialize(target, _reparse)
          rbs_loader = RBS::EnvironmentLoader.new(core_root: nil)
          rbs_loader.add(path: Pathname(target))
          @rbs_env = RBS::Environment.from_loader(rbs_loader).resolve_type_names
          return unless @rbs_env.declarations.empty?

          puts "WARNING: could not find RBS signatures for target directory '#{target}'. " \
          'Confirm that the directory exists and/or that it contains .rbs files.'
        end

        #  ruby -e "require 'rbs';loader=RBS::EnvironmentLoader.new(core_root: nil);loader.add(path:Pathname('sig'));environment=RBS::Environment.from_loader(loader);environment.declarations.each{|cls,entries|pp cls;pp entries}"
        def build
          @rbs_env.declarations.map { |decl| build_object(decl) }.compact
        end

        def build_object(object)
          case object
          when RBS::AST::Declarations::Class
            children = object.members.map { |child| build_object(child) }.compact
            ClassDefinition.new(
              name: object.name.relative!.to_s,
              source: build_source(object),
              parent: object.super_class&.to_s,
              type_parameters: object.type_params.map(&:name),
              children: children
            )
          when RBS::AST::Declarations::Module
            children = object.members.map { |child| build_object(child) }.compact
            ModuleDefinition.new(
              name: object.name.relative!.to_s,
              source: build_source(object),
              type_parameters: object.type_params.map(&:name),
              children: children
            )
          when RBS::AST::Members::MethodDefinition
            # NOTE: Currently only looking at first overload and
            # only at required positionals.
            sig = object.overloads.first.method_type.type
            parameters = sig.required_positionals.map do |param|
              ParameterDefinition.new(
                name: param.name,
                source: build_source(param),
                types: build_types(param.type),
                types_string: param.type.to_s
              )
            end
            return_sig = sig.return_type
            returns = ReturnDefinition.new(
              source: build_source(return_sig),
              types: build_types(return_sig),
              types_string: return_sig.to_s
            )
            MethodDefinition.new(
              name: object.name,
              source: build_source(object),
              scope: object.kind,
              visibility: object.visibility,
              parameters: parameters,
              returns: returns
            )
          else raise "Unsupported RBS declaration #{object.class}"
          end
        end

        def build_types(rbs_type)
          if rbs_type
            [Typeguard::TypeModel::Mapper::RBSMapper.parse_map(rbs_type)]
          else
            [TypeNode.new(
              kind: :untyped,
              shape: :untyped,
              children: [],
              metadata: { note: 'RBS type not provided' }
            )]
          end
        end

        def build_source(object)
          location = object.location
          "#{location.buffer.name}:#{location.start_line}"
        end
      end
    end
  end
end
