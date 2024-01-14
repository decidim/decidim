# frozen_string_literal: true

require "rails"
require "active_support/all"

require "devise"
require "devise-i18n"
require "decidim/core"
require "decidim/system/menu"
require "foundation_rails_helper"

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
    end
  end
end
