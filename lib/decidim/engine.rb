# frozen_string_literal: true

module Decidim
  class Engine < ::Rails::Engine
    config.app_middleware.use(
      Rack::Static,
      # note! this varies from the Webpacker/engine documentation
      urls: ["/decidim-packs"], root: Decidim::Engine.root #.join("decidim-packs")
      # urls: ["/decidim-packs"], root: "decidim-packs"
      # instead of -> urls: ["/decidim-packs"], root: "decidim/public"
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
