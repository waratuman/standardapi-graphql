$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "standard_api"
require "standard_api/graphql"
require "standard_api/test_app"
require "minitest/autorun"

module NameSpaced
  class Model < ::ActiveRecord::Base
    self.table_name = "namespaced_models"
  end
end

class CreateNameSpacedModelTables < ActiveRecord::Migration[6.0]

  def self.up
    create_table "namespaced_models", force: :cascade do |t|
      t.string   'name',                 limit: 255
    end
  end

end

ActiveRecord::Migration.verbose = false
CreateNameSpacedModelTables.up

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

Rails.backtrace_cleaner.remove_silencers!
