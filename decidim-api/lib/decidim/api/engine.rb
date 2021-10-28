# frozen_string_literal: true

require "graphql"
require "rack/cors"

require "decidim/core"
require "decidim/api/graphiql/config"

if ActiveSupport::Inflector.method(:inflections).arity.zero?
  # Rails 3 does not take a language in inflections.
  ActiveSupport::Inflector.inflections do |inflect|
    inflect.acronym("GraphiQL")
  end
else
  ActiveSupport::Inflector.inflections(:en) do |inflect|
    inflect.acronym("GraphiQL")
  end
end

module Decidim
  module Api
    # Mountable engine that exposes a side-wide API for Decidim.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Api

      initializer "decidim-api.middleware" do |app|
        app.config.middleware.insert_before 0, Rack::Cors do
          allow do
            origins "*"
            resource "/api", headers: :any, methods: [:post, :options]
          end
        end
      end

      initializer "decidim-api.graphiql" do
        Decidim::GraphiQL::Rails.config.tap do |config|
          config.query_params = true
          config.initial_query = File.read(
            File.join(__dir__, "graphiql-initial-query.txt")
          ).html_safe
        end
      end

      initializer "decidim_api.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
