module StandardAPI
  module Graphql
    module Types
      class BaseObject < ::GraphQL::Schema::Object
        field_class Types::BaseField
      end
    end
  end
end
