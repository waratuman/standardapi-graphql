$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "standard_api"
require "standard_api/graphql"
require "standard_api/test_app"
require "minitest/autorun"

class GraphqlController < ApplicationController
  include StandardAPI::Graphql::Controller

end

Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
end

include ActionDispatch::TestProcess

class ActionDispatch::IntegrationTest
  include ActiveRecord::TestFixtures
  include FactoryBot::Syntax::Methods
end
