# frozen_string_literal: true
require "graphql"
require "graphiql/rails"
require "rack/cors"
require "sprockets/es6"

module Decidim
  module Api
    # Mountable engine that exposes a side-wide API for Decidim.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Api

      initializer "decidim_api.assets" do |app|
        app.config.assets.precompile += %w(decidim_api_manifest.js)
      end

      initializer "decidim-api.middleware" do |app|
        app.config.middleware.insert_before 0, Rack::Cors do
          allow do
            origins "*"
            resource "*", headers: :any, methods: [:get, :post, :options]
          end
        end
      end

      initializer "decidim-api.graphiql" do
        GraphiQL::Rails.config.tap do |config|
          config.query_params = true
          config.initial_query = File.read(
            File.join(File.dirname(__FILE__), "graphiql-initial-query.txt")
          ).html_safe
        end
      end
    end
  end
end
