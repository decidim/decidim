# frozen_string_literal: true
module Decidim
  # A middleware that enhances the request with the current organization based
  # on the hostname.
  class CurrentOrganization
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
      env["decidim.current_organization"] = detect_current_organization(env)
      @app.call(env)
    end

    private

    def detect_current_organization(env)
      host = Rack::Request.new(env).host.downcase
      Decidim::Organization.where(host: host).first
    end
  end
end
