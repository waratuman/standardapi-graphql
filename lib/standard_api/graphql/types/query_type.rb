module StandardAPI
  module Graphql
    module Types
      class QueryType < BaseObject
        include StandardAPI::Helpers

        class << self

          def irep_node_includes(model, typed_children)
            includes = {}

            typed_children.each do |obj_type, children|
              children.each do |name, node|
                association = model.reflect_on_association(name)

                if association
                  includes[name] = irep_node_includes(association.klass, node.typed_children)
                else
                end
              end
            end
            includes
          end

          def add_model(model)
            return if model.abstract_class

            includes = model.reflect_on_all_associations.map(&:name)
            type = Types.define_type(model, includes)
            order_type = Types.define_order_type(model, includes)
            predicate_type = Types.define_predicate_type(model, includes)

            field model.graphql_field_name(true), type: [type], null: false do
              argument :limit, ::GraphQL::Types::Int, required: false, default_value: 1000
              argument :offset, ::GraphQL::Types::Int, required: false, default_value: 0
              argument :order, order_type, required: false, default_value: nil
              argument :where, predicate_type, required: false, default_value: {}
            end

            define_method(model.graphql_field_name(true)) do |limit:, offset:, order:, where:|
              node = context.irep_node.typed_children.values[0][model.graphql_field_name(true)]
              includes = QueryType.irep_node_includes(model, node.typed_children)

              resources = model.filter(where.to_h).limit(limit).offset(offset).sort(order.to_h)
              preloadables(resources, includes)
            end

            field model.graphql_field_name, type: type, null: true do
              if model.primary_key
                arg_type = Types.column_graphql_type(model, model.columns.find { |x| x.name == model.primary_key })
                argument :id, arg_type, required: true
              end
            end

            define_method(model.graphql_field_name) do |id:|
              model.find(id)
            end

          end

        end

      end
    end
  end
end
