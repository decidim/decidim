# frozen_string_literal: true

require "rails"
require "active_support/all"

require "devise"
require "devise-i18n"
require "decidim/core"
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

      initializer "decidim_admin.register_icons" do |_app|
        Decidim.icons.register(name: "lock-2-line", icon: "lock-2-line", category: "system", description: "Block user icon", engine: :admin)
        Decidim.icons.register(name: "layout-masonry-line", icon: "layout-masonry-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "service-line", icon: "service-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "fullscreen-line", icon: "fullscreen-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "lock-line", icon: "lock-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "download-line", icon: "download-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "mail-open-line", icon: "mail-open-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "forbid-2-line", icon: "forbid-2-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "key-2-line", icon: "key-2-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "arrow-go-back-line", icon: "arrow-go-back-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "computer-line", icon: "computer-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "arrow-right-s-line", icon: "arrow-right-s-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "arrow-up-line", icon: "arrow-up-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "arrow-down-line", icon: "arrow-down-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "line-chart", icon: "line-chart-line", category: "system", description: "Line chart", engine: :admin)
        Decidim.icons.register(name: "bar-chart-box-line", icon: "bar-chart-box-line", category: "system", description: "Bar chart box line", engine: :admin)
        Decidim.icons.register(name: "earth-line", icon: "earth-line", category: "system", description: "Earth line", engine: :admin)

        Decidim.icons.register(name: "attachment-2", icon: "attachment-2", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "spy-line", icon: "spy-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "refresh-line", icon: "refresh-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "zoom-in-line", icon: "zoom-in-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "add-line", icon: "add-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "upload-line", icon: "upload-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "settings-4-line", icon: "settings-4-line", category: "system", description: "", engine: :admin)

        Decidim.icons.register(name: "folder-line", icon: "folder-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "attachment-line", icon: "attachment-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "delete-bin-2-line", icon: "delete-bin-2-line", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "filter-line", icon: "filter-line", category: "system", description: "", engine: :admin)
      end

      initializer "decidim_admin.mime_types" do |_app|
        # Required for importer example downloads
        Mime::Type.register Decidim::Admin::Import::Readers::XLSX::MIME_TYPE, :xlsx
      end

      initializer "decidim_admin.menu" do
        Decidim::Admin::Menu.register_admin_global_moderation_menu!
        Decidim::Admin::Menu.register_workflows_menu!
        Decidim::Admin::Menu.register_impersonate_menu!
        Decidim::Admin::Menu.register_admin_static_pages_menu!
        Decidim::Admin::Menu.register_admin_insights_menu!
        Decidim::Admin::Menu.register_admin_user_menu!
        Decidim::Admin::Menu.register_admin_scopes_menu!
        Decidim::Admin::Menu.register_admin_areas_menu!
        Decidim::Admin::Menu.register_admin_settings_menu!
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
