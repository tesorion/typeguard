# frozen_string_literal: true

module Yard
  module TypeModel
    module Builder
      class YardBuilder
        include Yard::TypeModel::Definitions
        require 'yard'
        # ruby -e "require 'yard';YARD::Registry.load('.yardoc');YARD::Registry.all.each {|m|pp m;m.tags.each {|t|pp t};puts }"

        # @see https://rubydoc.info/gems/yard/YARD/Registry
        # @param reparse_files [Boolean] has no effect if target is a string.
        #   If false and target is an array, the files are only reparsed if no .yardoc is present.
        #   If true and target is an array, the files are always reparsed.
        def initialize(target, reparse_files)
          return unless YARD::Registry.load(target, reparse_files).root.children.empty?

          if target.is_a?(String)
            puts "WARNING: could not find YARD objects for target directory '#{target}'. " \
            "Confirm that the directory exists and/or execute 'yardoc [...]' again."
          else
            puts "WARNING: could not find YARD objects for target files after reparsing array #{target}. " \
            "Confirm that the files exist and/or execute 'yardoc #{target.join(' ')}' again in the correct directory."
          end
        end

        def build
          YARD::Registry.root.children.map { |child| build_object(child) }.compact
        end

        def build_object(object)
          case object
          when YARD::CodeObjects::NamespaceObject
            members = object.children.map { |child| build_object(child) }.compact

            # TODO: type parameters? #initialize captured by :methods
            if object.is_a?(YARD::CodeObjects::ClassObject)
              ClassDefinition.new(
                name: object.path,
                source: "#{object.file}:#{object.line}",
                parent: object.superclass&.path,
                type_parameters: nil,
                members: members
              )
            else
              ModuleDefinition.new(
                name: object.path,
                source: "#{object.file}:#{object.line}",
                type_parameters: nil,
                members: members
              )
            end
          when YARD::CodeObjects::MethodObject
            parameters = object.tags(:param).map do |tag|
              ParameterDefinition.new(
                name: tag.name.to_sym,
                source: "#{object.file}:#{object.line}",
                types: build_types(tag),
                type_strings: tag.types
              )
            end
            return_tag = object.tag(:return)
            returns = ReturnDefinition.new(
              source: "#{object.file}:#{object.line}",
              types: build_types(return_tag),
              type_strings: return_tag.respond_to?(:types) ? return_tag.types : []
            )
            MethodDefinition.new(
              name: object.name,
              source: "#{object.file}:#{object.line}",
              scope: object.scope,
              visibility: object.visibility,
              parameters: parameters,
              returns: returns
            )
          when YARD::CodeObjects::ConstantObject, YARD::CodeObjects::ClassVariableObject
            raise "Not implemented: #{object.class}"
          else
            raise "Unsupported YARD object: #{object.class}"
          end
        end

        def build_types(tag)
          if tag.respond_to?(:types) && !tag.types.empty?
            tag.types.map do |type|
              Yard::TypeModel::Parser::YardParser.parse(type)
            end
          else
            [] << TypeNode.new(
              kind: :untyped,
              shape: :untyped,
              children: [],
              metadata: { note: 'Types specifier list is empty: untyped' }
            )
          end
        end
      end

      class RBSBuilder
        require 'rbs'
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
        def initialize(target)
          rbs_loader = RBS::EnvironmentLoader.new(core_root: nil)
          rbs_loader.add(path: Pathname(target))
          @rbs_env = RBS::Environment.from_loader(rbs_loader)
        end
      end
    end
  end
end
