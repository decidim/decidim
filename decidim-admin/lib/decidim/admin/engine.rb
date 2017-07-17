# frozen_string_literal: true

require "rails"
require "active_support/all"

require "devise"
require "devise-i18n"
require "decidim/core"
require "jquery-rails"
require "sassc-rails"
require "foundation-rails"
require "foundation_rails_helper"
require "autoprefixer-rails"
require "rectify"

require_dependency File.join(__dir__, "..", "..", "..", "app/models/decidim/admin/abilities/admin_user")

module Decidim
  module Admin
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Admin

      initializer "decidim_admin.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::Admin::Engine => "/admin"
        end
      end

      initializer "decidim_admin.assets" do |app|
        app.config.assets.precompile += %w(decidim_admin_manifest.js)
      end

      initializer "decidim_admin.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += ["Decidim::Admin::Abilities::AdminUser"]
          config.admin_abilities += ["Decidim::Admin::Abilities::ParticipatoryProcessAdminUser"]
          config.admin_abilities += ["Decidim::Admin::Abilities::ParticipatoryProcessCollaboratorUser"]
        end
      end

      initializer "decidim_admin.menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.dashboard", scope: "decidim.admin"),
                    decidim_admin.root_path,
                    icon_name: "dashboard",
                    position: 1,
                    active: ["decidim/admin/dashboard" => :show]

          menu.item I18n.t("menu.participatory_processes", scope: "decidim.admin"),
                    decidim_admin.participatory_processes_path,
                    icon_name: "target",
                    position: 2,
                    active: :inclusive

          menu.item I18n.t("menu.participatory_process_groups", scope: "decidim.admin"),
                    decidim_admin.participatory_process_groups_path,
                    icon_name: "layers",
                    position: 3,
                    active: :inclusive,
                    if: can?(:read, Decidim::ParticipatoryProcessGroup)

          menu.item I18n.t("menu.static_pages", scope: "decidim.admin"),
                    decidim_admin.static_pages_path,
                    icon_name: "book",
                    position: 4,
                    active: :inclusive,
                    if: can?(:read, Decidim::StaticPage)

          menu.item I18n.t("menu.users", scope: "decidim.admin"),
                    decidim_admin.users_path,
                    icon_name: "person",
                    position: 5,
                    active: [%w(decidim/admin/user_groups decidim/admin/users), []],
                    if: can?(:read, :admin_users)

          menu.item I18n.t("menu.newsletters", scope: "decidim.admin"),
                    decidim_admin.newsletters_path,
                    icon_name: "envelope-closed",
                    position: 6,
                    active: :inclusive,
                    if: can?(:index, Decidim::Newsletter)

          menu.item I18n.t("menu.settings", scope: "decidim.admin"),
                    decidim_admin.edit_organization_path,
                    icon_name: "wrench",
                    position: 7,
                    active: [%w(decidim/admin/organization decidim/admin/scopes), []],
                    if: can?(:read, current_organization)
        end
      end
    end
  end
end
