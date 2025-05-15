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
          @object_vars = {}
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
          # Deduplicated tree-like structure where the root is an array of
          # objects whose parent is undefined or YARD root/proxy
          YARD::Registry.all(:class, :module, :method).filter_map do |object|
            build_object(object) if object.parent.nil? || %i[root proxy].include?(object.parent.type)
          end
        end

        def build_object(object)
          case object.type
          when :class
            children = object.children.map { |child| build_object(child) }.compact
            ClassDefinition.new(
              name: object.path.gsub('.self', ''),
              source: "#{object.file}:#{object.line}",
              vars: build_inherit_vars(object),
              parent: object.superclass&.path,
              type_parameters: nil,
              children: children
            )
          when :module
            children = object.children.map { |child| build_object(child) }.compact
            ModuleDefinition.new(
              name: object.path.gsub('.self', ''),
              source: "#{object.file}:#{object.line}",
              vars: build_inherit_vars(object),
              type_parameters: nil,
              children: children
            )
          when :method
            return_tag = object.tag(:return)
            returns = ReturnDefinition.new(
              source: "#{object.file}:#{object.line}",
              types: build_types(return_tag),
              types_string: build_types_string(return_tag)
            )
            MethodDefinition.new(
              name: object.name,
              source: "#{object.file}:#{object.line}",
              scope: object.scope,
              visibility: object.visibility,
              parameters: build_parameters(object),
              returns: returns
            )
          when :constant, :classvariable, :proxy
            # Covered by build_vars and build
          else
            raise "Unsupported YARD object: #{object.class}"
          end
        end

        def build_parameters(object)
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
              types_string: build_types_string(tag)
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

          parameters
        end

        def build_inherit_vars(object)
          # Looks at mixins and superclasses to build a full set
          # of (inherited) vars, order-preserved such that the
          # narrowest namespace takes precedence: if class A and
          # B < A define attribute c, the definition of A::B holds
          # pp "build_inherit_vars for #{object}"
          # object.inheritance_tree(true).flat_map do |inherited|
          object.inheritance_tree(true).flat_map do |inherited|
            @object_vars[inherited] ||= build_vars(inherited)
          end.uniq(&:name)
        end

        def build_vars(object)
          return [] unless %i[class module].include?(object.type)

          # NOTE: When a module is defined with .self syntax
          # and also referenced with :: syntax, the reference
          # is interpreted as a proxy. You could eventually
          # find the actual code object, but iteratively
          # replacing every :: with .self or vice versa and
          # performing the lookup is not very nice. So, we
          # simply don't propagate in this case.
          return [] if object.is_a? YARD::CodeObjects::Proxy

          vars = []
          object.cvars.each do |cvar|
            return_tag = cvar.tag(:return)
            vars << VarDefinition.new(
              name: cvar.name,
              source: "#{cvar.file}:#{cvar.line}",
              scope: :class,
              types: build_types(return_tag),
              types_string: build_types_string(return_tag)
            )
          end
          object.constants.each do |const|
            return_tag = const.tag(:return)
            vars << VarDefinition.new(
              name: const.name,
              source: "#{const.file}:#{const.line}",
              scope: :constant,
              types: build_types(return_tag),
              types_string: build_types_string(return_tag)
            )
          end
          object.attributes[:instance].each do |key, value|
            method = value[:read]
            return_tag = method.tag(:return)
            vars << VarDefinition.new(
              name: "@#{key}".to_sym,
              source: "#{method.file}:#{method.line}",
              scope: :instance,
              types: build_types(return_tag),
              types_string: build_types_string(return_tag)
            )
          end
          object.attributes[:class].each do |key, value|
            method = value[:read]
            return_tag = method.tag(:return)
            vars << VarDefinition.new(
              name: key,
              source: "#{method.file}:#{method.line}",
              scope: :self,
              types: build_types(return_tag),
              types_string: build_types_string(return_tag)
            )
          end

          vars
        end

        def build_types(tag)
          if tag.respond_to?(:types) && tag.types && !tag.types.empty?
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

        def build_types_string(tag)
          tag.respond_to?(:types) && !tag.types.nil? ? tag.types.join(' or ') : []
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
