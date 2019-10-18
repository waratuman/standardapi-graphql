module StandardAPI
  module Graphql
    module Types
      module BaseInterface
        include ::GraphQL::Schema::Interface

        field_class Types::BaseField
      end
    end
  end
end
