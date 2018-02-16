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
      organization = detect_current_organization(env)
      if organization
        env["decidim.current_organization"] = organization
        @app.call(env)
      else
        organization = find_secondary_host_org(env)
        return @app.call(env) unless organization

        location = new_location_for(env, organization.host)

        [301, { "Location" => location, "Content-Type" => "text/html", "Content-Length" => "0" }, []]
      end
    end

    private

    def detect_current_organization(env)
      host = host_for(env)
      Decidim::Organization.where(host: host).first
    end

    def find_secondary_host_org(env)
      host = host_for(env)
      Decidim::Organization.where("? = ANY(secondary_hosts)", host).first
    end

    def host_for(env)
      Rack::Request.new(env).host.downcase
    end

    def new_location_for(env, host)
      request = Rack::Request.new(env)
      url = URI(request.url)
      url.host = host
      url.to_s
    end
  end
end
