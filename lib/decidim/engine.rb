module Decidim
  class Engine < ::Rails::Engine
    config.app_middleware.use(
      Rack::Static,
      # note! this varies from the Webpacker/engine documentation
      urls: ["/decidim-packs"], root: Decidim::Engine.root.join("public")
      # instead of -> urls: ["/decidim-packs"], root: "decidim/public"
    )

    initializer "webpacker.proxy" do |app|
      insert_middleware = begin
                            Decidim.webpacker.config.dev_server.present?
                          rescue
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
