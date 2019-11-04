module StandardAPI
  module Graphql
    module Types
      ::GraphQL::Types.constants.each do |type|
        type_class_name = "#{type.to_s}PredicateType"

        type = :String if type == :ID
        type = ::GraphQL::Types.const_get(type)

        type_class = Class.new(BaseInputObject) do
          argument :eq, type, required: false
          argument :neq, type, required: false
          argument :lt, type, required: false
          argument :lte, type, required: false
          argument :gt, type, required: false
          argument :gte, type, required: false

          argument :like, type, required: false
          argument :ilike, type, required: false
          argument :in, [type], required: false
          argument :notIn, [type], required: false
          argument :overlaps, [type], required: false

          argument :null, ::GraphQL::Types::Boolean, required: false
        end

        type_class = const_set(type_class_name, type_class)
      end

      class << self

        def predicate_for(type)
          type_class_name = case type
          when Array
            type.map { |x| predicate_for(x) }
          else
            const_get "#{type.to_s.demodulize}PredicateType"
          end
        end

      end

    end
  end
end
