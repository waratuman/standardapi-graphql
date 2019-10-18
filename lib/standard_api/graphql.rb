require "graphql"
require "logger"
require "standard_api/graphql/version"

class ActiveRecord::Base

  def self.graphql_name
    to_s.gsub('::', '__')
  end

  def self.graphql_field_name(plural=false)
    if plural
      (to_s.split('::')[0..-2] + [model_name.plural.camelize]).join('__').camelize(:lower)
    else
      graphql_name.camelize(:lower)
    end
  end

end

module StandardAPI
  module Graphql
    class Error < StandardError; end
  end
end

require "standard_api/graphql/types"
require "standard_api/graphql/schema"
require "standard_api/graphql/controller"
