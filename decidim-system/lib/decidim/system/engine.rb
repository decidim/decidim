# frozen_string_literal: true

require "rails"
require "active_support/all"

require "devise"
require "devise-i18n"
require "decidim/core"
require "decidim/system/menu"

module Decidim
  module System
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::System

      initializer "decidim_system.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::System::Engine => "/system"
        end
      end

      initializer "decidim_system.menu" do
        Decidim::System::Menu.register_system_menu!
      end

      initializer "decidim_system.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_system.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::System::Engine.root}/app/cells")
      end
    end
  end
end
