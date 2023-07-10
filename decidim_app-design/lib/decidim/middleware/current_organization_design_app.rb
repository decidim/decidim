# frozen_string_literal: true

module Decidim
  module Middleware
    # A middleware that enhances the request with the current organization based
    # on the hostname.
    class CurrentOrganizationDesignApp
      # Initializes the Rack Middleware.
      #
      # app - The Rack application
      def initialize(app)
        @app = app
      end

      # Main entry point for a Rack Middleware.
      #
      # env - A Hash.
      def call(env)
        organization = Decidim::Organization.first
        if organization
          env["decidim.current_organization"] = organization
          @app.call(env)
        end
      end
    end
  end
end
