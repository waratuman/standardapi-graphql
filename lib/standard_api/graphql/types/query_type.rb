module StandardAPI
  module Graphql
    module Types
      class QueryType < BaseObject

        class << self

          def add_model(model)
            return if model.abstract_class

            includes = model.reflect_on_all_associations.map(&:name)
            type = Types.define_type(model, includes)

            field model.graphql_field_name(true), type: [type], null: false

            define_method(model.graphql_field_name(true)) do
              model.all
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

          def load_controllers
            Rails.application.eager_load! if !Rails.application.config.eager_load

            controllers = ApplicationController.descendants
            controllers.select! do |c|
              c.ancestors.include?(StandardAPI::Controller)  && !c.ancestors.include?(StandardAPI::Graphql::Controller)
            end

            controllers.each do |controller|
              add_controller(controller)
            end
          end
  
          def add_controller(controller)
            return if !controller.model

            controller.action_methods.each do |action|
              add_action_fn = "add_#{action}_action"
              next if !respond_to?(add_action_fn)
  
              send(add_action_fn, controller)
            end
          end
    
          def add_index_action(controller)
            model = controller.model
            type = Types.define_type(model, controller.new.send(:model_includes))
            field model.model_name.plural, type: [type], null: false
          end

        end

      end
    end
  end
end
