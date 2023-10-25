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
        Decidim.menu :admin_global_moderation_menu do |menu|
          moderations_count = Decidim::Admin::ModerationStats.new(current_user).count_content_moderations

          caption = I18n.t("menu.content", scope: "decidim.admin")
          caption += content_tag(:span, moderations_count, class: moderations_count.zero? ? "component-counter component-counter--off" : "component-counter")

          menu.add_item :moderations,
                        caption.html_safe,
                        decidim_admin.moderations_path,
                        position: 1,
                        active: is_active_link?(decidim_admin.moderations_path),
                        if: allowed_to?(:read, :global_moderation)

          user_reports = Decidim::Admin::ModerationStats.new(current_user).count_user_pending_reports

          caption = I18n.t("menu.reported_users", scope: "decidim.admin")
          caption += content_tag(:span, user_reports, class: user_reports.zero? ? "component-counter component-counter--off" : "component-counter")

          menu.add_item :moderated_users,
                        caption.html_safe,
                        decidim_admin.moderated_users_path,
                        active: is_active_link?(decidim_admin.moderated_users_path),
                        if: allowed_to?(:index, :moderate_users)
        end
      end

      initializer "decidim_admin.workflows_menu" do
        Decidim.menu :workflows_menu do |menu|
          Decidim::Verifications.admin_workflows.each do |manifest|
            next unless current_organization.available_authorizations.include?(manifest.name.to_s)

            workflow = Decidim::Verifications::Adapter.new(manifest)

            menu.add_item manifest.name.to_s,
                          workflow.fullname,
                          workflow.admin_root_path,
                          active: is_active_link?(workflow.admin_root_path)
          end
        end
      end

      initializer "decidim_admin.impersonate_menu" do
        Decidim.menu :impersonate_menu do |menu|
          menu.add_item :conflicts,
                        I18n.t("title", scope: "decidim.admin.conflicts"),
                        decidim_admin.conflicts_path,
                        active: is_active_link?(decidim_admin.conflicts_path),
                        if: allowed_to?(:index, :impersonatable_user)
        end
      end

      initializer "decidim_admin.user_menu" do
        Decidim.menu :admin_user_menu do |menu|
          menu.add_item :users,
                        I18n.t("menu.admins", scope: "decidim.admin"), decidim_admin.users_path,
                        icon_name: "user-line",
                        active: is_active_link?(decidim_admin.users_path),
                        if: allowed_to?(:read, :admin_user)
          menu.add_item :user_groups,
                        I18n.t("menu.user_groups", scope: "decidim.admin"), decidim_admin.user_groups_path,
                        icon_name: "group-line",
                        active: is_active_link?(decidim_admin.user_groups_path),
                        if: current_organization.user_groups_enabled? && allowed_to?(:index, :user_group)
          menu.add_item :officializations,
                        I18n.t("menu.participants", scope: "decidim.admin"), decidim_admin.officializations_path,
                        icon_name: "service-line",
                        active: is_active_link?(decidim_admin.officializations_path),
                        if: allowed_to?(:index, :officialization)
          menu.add_item :impersonatable_users,
                        I18n.t("menu.impersonations", scope: "decidim.admin"), decidim_admin.impersonatable_users_path,
                        icon_name: "user-add-line",
                        active: is_active_link?(decidim_admin.impersonatable_users_path),
                        if: allowed_to?(:index, :impersonatable_user),
                        submenu: { target_menu: :impersonate_menu }
          menu.add_item :authorization_workflows,
                        I18n.t("menu.authorization_workflows", scope: "decidim.admin"), decidim_admin.authorization_workflows_path,
                        icon_name: "key-2-line",
                        active: is_active_link?(decidim_admin.authorization_workflows_path),
                        if: allowed_to?(:index, :authorization),
                        submenu: { target_menu: :workflows_menu }
        end
      end

      initializer "decidim_admin.scopes_menu" do
        Decidim.menu :admin_scopes_menu do |menu|
          menu.add_item :scopes,
                        I18n.t("menu.scopes", scope: "decidim.admin"),
                        decidim_admin.scopes_path,
                        icon_name: "price-tag-3-line",
                        position: 1.3,
                        if: allowed_to?(:read, :scope)
          menu.add_item :scope_types,
                        I18n.t("menu.scope_types", scope: "decidim.admin"),
                        decidim_admin.scope_types_path,
                        icon_name: "price-tag-3-line",
                        position: 1.4,
                        if: allowed_to?(:read, :scope_type)
        end
      end

      initializer "decidim_admin.areas_menu" do
        Decidim.menu :admin_areas_menu do |menu|
          menu.add_item :areas,
                        I18n.t("menu.areas", scope: "decidim.admin"),
                        decidim_admin.areas_path,
                        icon_name: "layout-masonry-line",
                        position: 1.5,
                        if: allowed_to?(:read, :area)

          menu.add_item :area_types,
                        I18n.t("menu.area_types", scope: "decidim.admin"),
                        decidim_admin.area_types_path,
                        icon_name: "layout-masonry-line",
                        position: 1.6,
                        if: allowed_to?(:read, :area_type)
        end
      end

      initializer "decidim_admin.settings_menu" do
        Decidim.menu :admin_settings_menu do |menu|
          menu.add_item :edit_organization,
                        I18n.t("menu.configuration", scope: "decidim.admin"),
                        decidim_admin.edit_organization_path,
                        position: 1.0,
                        icon_name: "pencil-line",
                        if: allowed_to?(:update, :organization, organization: current_organization)

          menu.add_item :edit_organization_appearance,
                        I18n.t("menu.appearance", scope: "decidim.admin"),
                        decidim_admin.edit_organization_appearance_path,
                        position: 1.1,
                        icon_name: "tools-line",
                        if: allowed_to?(:update, :organization, organization: current_organization)

          menu.add_item :edit_organization_homepage,
                        I18n.t("menu.homepage", scope: "decidim.admin"),
                        decidim_admin.edit_organization_homepage_path,
                        position: 1.2,
                        icon_name: "home-gear-line",
                        if: allowed_to?(:update, :organization, organization: current_organization)

          menu.add_item :scopes,
                        I18n.t("menu.scopes", scope: "decidim.admin"),
                        decidim_admin.scopes_path,
                        icon_name: "price-tag-3-line",
                        position: 1.3,
                        if: allowed_to?(:read, :scope)
          menu.add_item :areas,
                        I18n.t("menu.areas", scope: "decidim.admin"),
                        decidim_admin.areas_path,
                        icon_name: "layout-masonry-line",
                        position: 1.5,
                        if: allowed_to?(:read, :area)

          menu.add_item :help_sections,
                        I18n.t("menu.help_sections", scope: "decidim.admin"),
                        decidim_admin.help_sections_path,
                        icon_name: "question-line",
                        position: 1.6,
                        if: allowed_to?(:update, :help_sections)

          menu.add_item :external_domain_whitelist,
                        I18n.t("menu.external_domain_whitelist", scope: "decidim.admin"),
                        decidim_admin.edit_organization_external_domain_whitelist_path,
                        icon_name: "computer-line",
                        position: 1.7,
                        if: allowed_to?(:update, :organization, organization: current_organization)
        end
      end

      initializer "decidim_admin.menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :moderations,
                        I18n.t("menu.moderation", scope: "decidim.admin"),
                        decidim_admin.moderations_path,
                        icon_name: "flag-line",
                        position: 4,
                        active: [%w(
                          decidim/admin/global_moderations
                          decidim/admin/global_moderations/reports
                          decidim/admin/moderated_users
                        ), []],
                        if: allowed_to?(:read, :global_moderation) || allowed_to?(:index, :moderate_users)

          menu.add_item :static_pages,
                        I18n.t("menu.static_pages", scope: "decidim.admin"),
                        decidim_admin.static_pages_path,
                        icon_name: "pages-line",
                        position: 4.5,
                        active: is_active_link?(decidim_admin.static_pages_path, :inclusive) ||
                                is_active_link?(decidim_admin.static_page_topics_path, :inclusive),
                        if: allowed_to?(:read, :static_page)

          menu.add_item :impersonatable_users,
                        I18n.t("menu.users", scope: "decidim.admin"),
                        allowed_to?(:read, :admin_user) ? decidim_admin.users_path : decidim_admin.impersonatable_users_path,
                        icon_name: "team-line",
                        position: 5,
                        active: [%w(
                          decidim/admin/users
                          decidim/admin/user_groups
                          decidim/admin/user_groups_csv_verifications
                          decidim/admin/officializations
                          decidim/admin/impersonatable_users
                          decidim/admin/conflicts
                          decidim/admin/managed_users/impersonation_logs
                          decidim/admin/managed_users/promotions
                          decidim/admin/authorization_workflows
                          decidim/verifications/id_documents/admin/pending_authorizations
                          decidim/verifications/id_documents/admin/config
                          decidim/verifications/postal_letter/admin/pending_authorizations
                          decidim/verifications/csv_census/admin/census
                        ), []],
                        if: allowed_to?(:read, :admin_user) || allowed_to?(:read, :managed_user)

          menu.add_item :newsletters,
                        I18n.t("menu.newsletters", scope: "decidim.admin"),
                        decidim_admin.newsletters_path,
                        icon_name: "mail-add-line",
                        position: 6,
                        active: is_active_link?(decidim_admin.newsletters_path, :inclusive) ||
                                is_active_link?(decidim_admin.newsletter_templates_path, :inclusive),
                        if: allowed_to?(:index, :newsletter)

          menu.add_item :edit_organization,
                        I18n.t("menu.settings", scope: "decidim.admin"),
                        decidim_admin.edit_organization_path,
                        icon_name: "tools-line",
                        position: 7,
                        active: [
                          %w(
                            decidim/admin/organization
                            decidim/admin/organization_appearance
                            decidim/admin/organization_homepage
                            decidim/admin/organization_homepage_content_blocks
                            decidim/admin/scopes
                            decidim/admin/scope_types
                            decidim/admin/areas decidim/admin/area_types
                            decidim/admin/help_sections
                            decidim/admin/organization_external_domain_whitelist
                          ),
                          []
                        ],
                        if: allowed_to?(:update, :organization, organization: current_organization)

          menu.add_item :logs,
                        I18n.t("menu.admin_log", scope: "decidim.admin"),
                        decidim_admin.logs_path,
                        icon_name: "pages-line",
                        position: 10,
                        active: [%w(decidim/admin/logs), []],
                        if: allowed_to?(:read, :admin_log)
        end
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
