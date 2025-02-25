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

      initializer "decidim_api.configure" do |app|
        # Remove the default middleware as we configure Warden::JWTAuth manually
        # below, see `after_initialize`.
        app.initializers.find { |a| a.name == "devise-jwt-middleware" }.context_class.instance.initializers.reject! { |a| a.name == "devise-jwt-middleware" }
      end

      initializer "decidim_api.middleware" do |app|
        app.config.middleware.insert_before 0, Rack::Cors do
          allow do
            origins "*"
            resource "/api/*", headers: :any, methods: [:post, :options]
          end
        end
      end

      initializer "decidim_api.graphiql" do
        Decidim::GraphiQL::Rails.config.tap do |config|
          config.query_params = true
          config.initial_query = ERB::Util.html_escape(
            File.read(File.join(__dir__, "graphiql-initial-query.txt"))
          )
        end
      end

      initializer "decidim_api.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      config.after_initialize do
        # Skip the warden configuration if JWT secret key is not defined (yet).
        next if Rails.application.secrets.secret_key_jwt.blank?

        # There is some problem setting these configurations to Devise::JWT,
        # so send them directly to the Warden module.
        #
        # See:
        # https://github.com/waiting-for-dev/devise-jwt/issues/159
        Warden::JWTAuth.configure do |jwt|
          defaults = ::Devise::JWT::DefaultsGenerator.call

          jwt.mappings = defaults[:mappings]
          jwt.secret = Rails.application.secrets.secret_key_jwt
          jwt.dispatch_requests = [
            ["POST", %r{^/sign_in$}]
          ]
          jwt.revocation_requests = [
            ["DELETE", %r{^/sign_out$}]
          ]
          jwt.revocation_strategies = defaults[:revocation_strategies]
          jwt.expiration_time = 1.day.to_i
          jwt.aud_header = "JWT_AUD"
        end
      end
    end
  end
end
