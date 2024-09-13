# frozen_string_literal: true

require "decidim/dev/needs_development_tools"

module Decidim
  module Dev
    # Example engine overriding the core authentication routes.
    class AuthEngine < ::Rails::Engine
      isolate_namespace Decidim::Dev
      engine_name "decidim_dev_auth"

      routes do
        devise_scope :user do
          match(
            "/users/auth/test/callback",
            to: "omniauth_callbacks#dev_callback",
            as: "user_test_omniauth_authorize",
            via: [:get, :post]
          )
        end
      end

      initializer "decidim_dev_auth.mount_test_routes", before: :add_routing_paths do
        next unless Rails.env.test?

        # Required for overriding the callback route.
        Decidim::Core::Engine.routes.prepend do
          mount Decidim::Dev::AuthEngine => "/"
        end
      end
    end
  end
end
