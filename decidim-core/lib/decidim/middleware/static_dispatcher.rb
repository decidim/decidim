# frozen_string_literal: true

module Decidim
  module Middleware
    # A middleware that handles static assets serving. This extends from
    # ActionDispatch::Static and adds the ability to serve compressed images
    # also when running under the puma server solely.
    #
    # On production environments, the static files should be served directly
    # from the HTTP server in front of the application. This mainly used for
    # development and testing environments but also serves as a backup option
    # to ensure these assets are transferred using proper compression.
    class StaticDispatcher < ActionDispatch::Static
      # Initializes the Rack Middleware.
      #
      # app - The Rack application
      # path - The root path for the static files
      # index - The index file route for folders
      # headers - Additional response headers
      def initialize(app, path, index: "index", headers: {})
        @app = app
        @file_handler = ActionDispatch::FileHandler.new(
          path,
          index:,
          headers:,
          compressible_content_types: %r{\A(?:(text|image)/|application/javascript)}
        )
      end
    end
  end
end
