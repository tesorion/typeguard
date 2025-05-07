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
          YARD::Registry.root.children.map { |child| build_object(child) }.compact
        end

        def build_object(object)
          case object.type
          when :class
            children = object.children.map { |child| build_object(child) }.compact

            ClassDefinition.new(
              name: object.path,
              source: "#{object.file}:#{object.line}",
              parent: object.superclass&.path,
              type_parameters: nil,
              children: children
            )
          when :module
            children = object.children.map { |child| build_object(child) }.compact

            ModuleDefinition.new(
              name: object.path,
              source: "#{object.file}:#{object.line}",
              type_parameters: nil,
              children: children
            )
          when :method
            unbound_children = object.tags(:option).each_with_object({}) do |tag, hash|
              index = tag.name.gsub(/:/, '')
              hash[index] ||= [[], []]
              key = build_symbol
              key.metadata[:key] = tag.pair.name.gsub(/:/, '')
              value = build_types(tag.pair)
              value.each { |node| node.metadata[:defaults] = tag.pair.defaults }
              hash[index].first << key
              hash[index].last << value
            end

            ps = object.parameters
            parameters = object.tags(:param).map do |tag|
              p_name, p_default = ps.find { |name, _| name.gsub(/[*:]/, '') == tag.name }
              next unless p_name

              bound_children = unbound_children.delete(tag.name)
              ParameterDefinition.new(
                name: tag.name.to_sym,
                source: "#{object.file}:#{object.line}",
                default: p_default,
                types: bound_children ? [build_fixed_hash(bound_children)] : build_types(tag),
                types_string: tag.types.join(' or ')
              )
            end

            unbound_children.each do |k, v|
              parameter = ParameterDefinition.new(
                name: k,
                source: "#{object.file}:#{object.line}",
                default: nil,
                types: [build_fixed_hash(v)],
                types_string: 'Hash'
              )
              parameters << parameter
            end

            return_tag = object.tag(:return)
            returns = ReturnDefinition.new(
              source: "#{object.file}:#{object.line}",
              types: build_types(return_tag),
              types_string: return_tag.respond_to?(:types) ? return_tag.types.join(' or ') : []
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

        def build_symbol
          Yard::TypeModel::Mapper::YardMapper.parse_map('Symbol')
        end

        def build_fixed_hash(children)
          node = Yard::TypeModel::Mapper::YardMapper.parse_map('Hash')
          node.shape = :fixed_hash
          node.children = children
          node.metadata[:note] = 'Hash specified via @options'
          node
        end
      end
    end
  end
end
