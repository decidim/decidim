# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

module Decidim
  module Design
    # This is the engine that runs on the public interface of `decidim-design`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Design

      initializer "decidim_design.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::Design::Engine => "/design"
        end
      end

      initializer "decidim_admin.register_icons" do
        Decidim.icons.register(name: "home-7-line", icon: "home-7-line", resource: "design", category: "system", description: "", engine: :design)
        Decidim.icons.register(name: "ruler-line", icon: "ruler-line", resource: "core", category: "system", description: "", engine: :design)
        Decidim.icons.register(name: "focus-line", icon: "focus-line", resource: "core", category: "system", description: "", engine: :design)
      end

      initializer "decidim_design.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Design::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Design::Engine.root}/app/views") # for partials
      end

      initializer "decidim_design.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
