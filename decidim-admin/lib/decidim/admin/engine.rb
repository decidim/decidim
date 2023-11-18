# frozen_string_literal: true

require "rails"
require "active_support/all"

require "devise"
require "devise-i18n"
require "decidim/core"
require "foundation_rails_helper"
require "doorkeeper"
require "doorkeeper-i18n"
require "hashdiff"

require "decidim/admin/menu"

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

      initializer "decidim_admin.mime_types" do |_app|
        # Required for importer example downloads
        Mime::Type.register Decidim::Admin::Import::Readers::XLSX::MIME_TYPE, :xlsx
      end

      initializer "decidim_admin.global_moderation_menu" do
        Decidim::Admin::Menu.register_admin_global_moderation_menu!
      end

      initializer "decidim_admin.workflows_menu" do
        Decidim::Admin::Menu.register_workflows_menu!
      end

      initializer "decidim_admin.impersonate_menu" do
        Decidim::Admin::Menu.register_impersonate_menu!
      end

      initializer "decidim_admin.static_pages_menu" do
        Decidim::Admin::Menu.register_admin_static_pages_menu!
      end

      initializer "decidim_admin.user_menu" do
        Decidim::Admin::Menu.register_admin_user_menu!
      end

      initializer "decidim_admin.scopes_menu" do
        Decidim::Admin::Menu.register_admin_scopes_menu!
      end

      initializer "decidim_admin.areas_menu" do
        Decidim::Admin::Menu.register_admin_areas_menu!
      end

      initializer "decidim_admin.settings_menu" do
        Decidim::Admin::Menu.register_admin_settings_menu!
      end

      initializer "decidim_admin.menu" do
        Decidim::Admin::Menu.register_admin_menu!
      end

      initializer "decidim_admin.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Admin::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Admin::Engine.root}/app/views") # for partials
      end

      initializer "decidim_admin.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_admin.register_events" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.admin.block_user:after") do |_event_name, data|
            Decidim::BlockUserMailer.notify(data[:resource], data.dig(:extra, :justification)).deliver_later
          end
        end
      end
    end
  end
end
