# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Forms
    # This is the engine that runs on the public interface of `decidim-forms`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Forms

      initializer "decidim_forms.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Forms::Engine.root}/app/cells")
      end

      initializer "decidim_forms.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_forms.importmap", before: "importmap" do |app|
        app.config.importmap.paths << Engine.root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << Engine.root.join("app/packs/src")
      end

      initializer "decidim_forms.importmap.assets", before: "importmap.assets" do |app|
        app.config.assets.paths << Engine.root.join("app/packs") if app.config.respond_to?(:assets)
      end
    end
  end
end
