module StandardAPI
  module Graphql
    class Schema < ::GraphQL::Schema

      def query
        return @standardapi_query if defined?(@standardapi_query)

        self.class.initialize_query
        @standardapi_query = Types::QueryType.graphql_definition
      end

      def self.initialize_query
        Rails.application.eager_load! if !Rails.application.config.eager_load
        models = ActiveRecord::Base.descendants.map(&:base_class).uniq
        models.each { |model| Types::QueryType.add_model(model) }
      end

      def self.load_model(model)
        Types::QueryType.add_model(model)
      end

    end
  end
end

