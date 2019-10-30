require "standard_api/graphql/types/base_argument"
require "standard_api/graphql/types/base_enum"
require "standard_api/graphql/types/base_field"
require "standard_api/graphql/types/base_input_object"
require "standard_api/graphql/types/base_interface"
require "standard_api/graphql/types/base_object"
require "standard_api/graphql/types/base_scalar"
require "standard_api/graphql/types/base_union"
require "standard_api/graphql/types/mutation_type"
require "standard_api/graphql/types/order_enum"
require "standard_api/graphql/types/query_type"

module StandardAPI
  module Graphql
    module Types

      class << self

        def define_type(model, includes=[])
          type_class_name = "#{model.graphql_name}Type"

          if const_defined?(type_class_name)
            type_class = const_get(type_class_name)
            define_type_includes(type_class = const_get(type_class_name), model, includes)
            return type_class
          end

          return if model.abstract_class?
          
          type_class = Class.new(BaseObject) {}

          model.columns.each do |column|
            type = Types.column_graphql_type(model, column)
            next if !type

            type_class.field name: column.name,
              type: type,
              null: column.null
          end

          type_class = const_set(type_class_name, type_class)

          define_type_includes(type_class, model, includes)

          type_class
        end

        def define_order_type(model, includes=[])
          type_class_name = "#{model.graphql_name}OrderType"

          if const_defined?(type_class_name)
            type_class = const_get(type_class_name)
            define_type_includes(type_class = const_get(type_class_name), model, includes)
            return type_class
          end

          return if model.abstract_class?

          type_class = Class.new(BaseInputObject) {}

          model.columns.each do |column|
            type = Types.column_graphql_type(model, column)
            next if !type

            type_class.argument name: column.name,
              type: OrderEnum,
              required: false
          end

          type_class = const_set(type_class_name, type_class)

          # TODO: Add relationships

          type_class
        end

        def define_type_includes(type, model, includes)
          includes.each do |include|
            next if type.fields[include]

            association = model.reflect_on_association(include)

            if association.polymorphic?
              Rails.logger.warn <<-LOG.strip_heredoc
                StandardAPI::Graphql does not support polymorphic relationships (#{model.to_s}##{association.name}).
              LOG
              next
            end

            if association
              association_type = define_type(association.klass)

              null = case association.macro
              when :has_one
                true
              when :belongs_to
                column = if model.respond_to?(:left_model) # HABTM Gernrated Model
                  model.columns.find { |x| x.name == model.left_model.name.foreign_key }
                else
                  model.columns.find { |x| x.name == association.foreign_key }
                end
                column.null
              when :has_many, :has_and_belongs_to_many
                false
              end

              type.field name: include,
                type: association.collection? ? [association_type] : association_type,
                null: null
            else
              Rails.logger.error "This is a method include, fix me"
            end
          end
        end

        def column_graphql_type(model, column)
          return ::GraphQL::Types::ID if model.primary_key == column.name

          type = case column.sql_type
          when 'string', 'text', /^varchar(\(\d+\))?/
            ::GraphQL::Types::String
          when /timestamp(\(\d+\))?/, 'timestamp without time zone'
            ::GraphQL::Types::ISO8601DateTime
          when 'datetime', 'time without time zone'
            ::GraphQL::Types::ISO8601DateTime
          when 'json'
            ::GraphQL::Types::JSON
          when 'bigint'
            ::GraphQL::Types::BigInt
          when 'integer'
            ::GraphQL::Types::Int
          when 'jsonb'
            ::GraphQL::Types::JSON
          when 'inet'
            ::GraphQL::Types::String
          when 'hstore'
            ::GraphQL::Types::JSON
          when 'date'
            ::GraphQL::Types::ISO8601Date
          when /numeric(\(\d+(,\d+)?\))?/
            ::GraphQL::Types::Float
          when 'double precision'
            ::GraphQL::Types::Float
          when 'ltree'
            ::GraphQL::Types::String
          when 'boolean'
            ::GraphQL::Types::Boolean
          when 'uuid'
            ::GraphQL::Types::String
          when /character varying(\(\d+\))?/
            ::GraphQL::Types::String
          when /^geometry/
            ::GraphQL::Types::String
          end

          if !type
            # raise "No known GraphQL type for #{column.sql_type}"
            Rails.logger.warn "No known GraphQL type for #{column.sql_type}"
          end

          if column.array
            type = [type]
          end

          type
        end

      end

    end
  end
end
