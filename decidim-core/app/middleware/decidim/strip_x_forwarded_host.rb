# frozen_string_literal: true

module Decidim
  class StripXForwardedHost
    def initialize(app)
      @app = app
    end

    def call(env)
      env["HTTP_X_FORWARDED_HOST"] = nil unless Decidim.follow_http_x_forwarded_host
      @app.call(env)
    end
  end
end
