# frozen_string_literal: true

require 'yard'

module Yard
  module TypeModel
    module Builder
      # Takes YARD documentation and returns a generic type model
      class YardBuilder
        include Yard::TypeModel::Definitions

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
          # ruby -e "require 'yard';YARD::Registry.load('.yardoc');YARD::Registry.all.each {|m|pp m;m.tags.each {|t|pp t};puts }"
          YARD::Registry.root.children.map { |child| build_object(child) }.compact
        end

        def build_object(object)
          case object.type
          when :class
            members = object.children.map { |child| build_object(child) }.compact

            # TODO: type parameters? #initialize captured by :methods
            ClassDefinition.new(
              name: object.path,
              source: "#{object.file}:#{object.line}",
              parent: object.superclass&.path,
              type_parameters: nil,
              members: members
            )
          when :module
            members = object.children.map { |child| build_object(child) }.compact

            ModuleDefinition.new(
              name: object.path,
              source: "#{object.file}:#{object.line}",
              type_parameters: nil,
              members: members
            )
          when :method
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
          when :constant, :classvariable
            raise "Not implemented: #{object.class}"
          else
            raise "Unsupported YARD object: #{object.class}"
          end
        end

        def build_types(tag)
          if tag.respond_to?(:types) && !tag.types.empty?
            tag.types.map { |t| Yard::TypeModel::Mapper::YardMapper.parse_map(t) }
          else
            result = TypeNode.new(
              kind: :untyped,
              shape: :untyped,
              children: [],
              metadata: { note: 'Types specifier list is empty: untyped' }
            )
            [result]
          end
        end
      end
    end
  end
end
