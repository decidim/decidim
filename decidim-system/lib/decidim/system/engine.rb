# frozen_string_literal: true

require "rails"
require "active_support/all"

require "devise"
require "devise-i18n"
require "decidim/core"
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
        Decidim.menu :system_menu do |menu|
          menu.add_item :root,
                        I18n.t("menu.dashboard", scope: "decidim.system"),
                        decidim_system.root_path,
                        position: 1,
                        active: ["decidim/system/dashboard" => :show]

          menu.add_item :organizations,
                        I18n.t("menu.organizations", scope: "decidim.system"),
                        decidim_system.organizations_path,
                        position: 2,
                        active: :inclusive

          menu.add_item :admins,
                        I18n.t("menu.admins", scope: "decidim.system"),
                        decidim_system.admins_path,
                        position: 3,
                        active: :inclusive

          menu.add_item :oauth_applications,
                        I18n.t("menu.oauth_applications", scope: "decidim.system"),
                        decidim_system.oauth_applications_path,
                        position: 4,
                        active: [%w(decidim/system/oauth_applications), []]
        end
      end

      initializer "decidim_system.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
