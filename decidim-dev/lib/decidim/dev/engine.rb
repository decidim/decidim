# frozen_string_literal: true

module Decidim
  module Dev
    # Decidim's development Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Dev
      engine_name "decidim_dev"

      initializer "decidim_dev.tools" do
        ActiveSupport.on_load :action_controller do
          ActionController::Base.include Decidim::Dev::NeedsDevelopmentTools
        end
      end

      initializer "decidim_dev.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_dev.importmap", before: "importmap" do |app|
        app.config.importmap.paths << Engine.root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << Engine.root.join("app/packs/src")
      end

      initializer "decidim_dev.importmap.assets", before: "importmap.assets" do |app|
        app.config.assets.paths << Engine.root.join("app/packs") if app.config.respond_to?(:assets)
      end
    end
  end
end
