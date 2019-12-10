require "graphql"
require "logger"
require "standard_api/graphql/version"

class ActiveRecord::Base

  def self.graphql_name
    name.gsub('::', '__')
  end

  def self.graphql_field_name(plural=false)
    if plural
      parts = name.split('::')
      parts.push(parts.pop.pluralize)
      parts.join('__').camelize(:lower)
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
