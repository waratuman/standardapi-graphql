module StandardAPI
  module Graphql
    class Schema < ::GraphQL::Schema

      # Move the initialize out of the execute path for performance.
      def self.execute(query_str = nil, **kwargs)
        initialize_query if !query
        super
      end

      def self.initialize_query
        Rails.application.eager_load! if !Rails.application.config.eager_load
        models = ActiveRecord::Base.descendants.map(&:base_class).uniq
        models.each { |model| Types::QueryType.add_model(model) }
        query Types::QueryType
      end

    end
  end
end
