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

      initializer "decidim_api.devise", before: "add_routing_paths" do |app|
        config.to_prepare do
          Decidim::User.include Decidim::Api::UserExtension
        end

        # Required for the development environment because otherwise the JWT
        # authentication strategy would be lost during code reloads.
        app.reloader.after_class_unload do
          Decidim::User.include Decidim::Api::UserExtension
        end
      end

      initializer "decidim_api.devise_jwt", after: "devise.secret_key" do
        Devise.jwt do |jwt|
          # In order to be compatible with the JWT authentication, we need to set these
          # configurations. JWT secret is being used by the devise-jwt to sign the
          # tokens, once the user authenticated. The token signature ensures the
          # validity of the token and that the user has not tampered with it. If the
          # secret is not set correctly, the API authentication does not work.
          #
          # Note that the `dispatch_requests` and `revocation_requests` paths are the
          # full paths because we do not want the JWT tokens to be dispatched or revoked
          # during normal Decidim user sign ins or sign outs. This also requires a small
          # override to `Warden::JWTAuth` which is defined at
          # `decidim-api/lib/warden/jwt_auth/decidim_overrides.rb`.
          jwt.secret = Decidim::Env.new("DECIDIM_API_JWT_SECRET").value || Devise.secret_key
          raise "Please define the secret key for Devise" unless jwt.secret

          jwt.dispatch_requests = [
            ["POST", %r{^/api/sign_in$}]
          ]
          jwt.revocation_requests = [
            ["DELETE", %r{^/api/sign_out$}]
          ]
          jwt.expiration_time = Decidim::Api.jwt_expires_in.minutes.to_i
          jwt.aud_header = "X_JWT_AUD"
        end
      end

      initializer "decidim_api.data_migrate", after: "decidim_core.data_migrate" do
        DataMigrate.configure do |config|
          config.data_migrations_path << root.join("db/data").to_s
        end
      end

      initializer "decidim_api.shakapacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
