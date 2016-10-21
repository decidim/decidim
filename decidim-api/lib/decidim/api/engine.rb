# frozen_string_literal: true
require "graphql"
require "graphiql/rails"
require "rack/cors"

module Decidim
  module Api
    # Mountable engine that exposes a side-wide API for Decidim.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Api

      initializer "decidim-api.middleware" do |app|
        app.config.middleware.insert_before 0, Rack::Cors do
          allow do
            origins "*"
            resource "*", headers: :any, methods: [:get, :post, :options]
          end
        end
      end
    end
  end
end
