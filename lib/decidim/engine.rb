# frozen_string_literal: true

module Decidim
  class Engine < ::Rails::Engine
    config.app_middleware.use(
      Rack::Static,
      urls: ["/decidim-packs"], root: Decidim::Engine.root
    )

    initializer "webpacker.proxy" do |app|
      insert_middleware = begin
        Decidim.webpacker.config.dev_server.present?
      rescue StandardError
        nil
      end
      next unless insert_middleware

      app.middleware.insert_before(
        0, Webpacker::DevServerProxy,
        ssl_verify_none: true,
        webpacker: Decidim.webpacker
      )
    end
  end
end
