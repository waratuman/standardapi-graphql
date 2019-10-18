module StandardAPI
  module Graphql
    class Railtie < ::Rails::Railtie

      initializer 'standardapi/graphql' do
        ActiveSupport.on_load(:standardapi) do
          ::ActionView::Base.send :include, StandardAPI::Helpers
          ::ActionDispatch::Routing::Mapper.send :include, StandardAPI::RouteHelpers
        end
      end

    end
  end
end
