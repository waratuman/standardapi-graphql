module StandardAPI
  module Graphql
    class Railtie < ::Rails::Railtie

      initializer 'standardapi/graphql' do
        ActiveSupport.on_load(:standardapi) do
        end
      end

    end
  end
end
