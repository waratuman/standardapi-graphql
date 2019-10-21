module StandardAPI
  module Graphql
    module Types
      class BaseField < ::GraphQL::Schema::Field
        argument_class Types::BaseArgument

        def resolve_field(obj, args, ctx)
          resolve(obj, args, ctx)
        end
      end
    end
  end
end
