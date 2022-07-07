# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module Assemblies
    # Decidim's Assemblies Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Assemblies::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :assemblies_types
        resource :assemblies_settings, only: [:edit, :update], controller: "assemblies_settings"

        resources :assemblies, param: :slug, except: [:show, :destroy] do
          resource :publish, controller: "assembly_publications", only: [:create, :destroy]
          resources :copies, controller: "assembly_copies", only: [:new, :create]
          resources :members, controller: "assembly_members"

          resources :user_roles, controller: "assembly_user_roles" do
            member do
              post :resend_invitation, to: "assembly_user_roles#resend_invitation"
            end
          end

          resources :attachment_collections, controller: "assembly_attachment_collections"
          resources :attachments, controller: "assembly_attachments"

          resource :export, controller: "assembly_exports", only: :create

          collection do
            resources :imports, controller: "assembly_imports", only: [:new, :create]
          end
        end

        scope "/assemblies/:assembly_slug" do
          resources :categories

          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
              get :share
            end
            resources :exports, only: :create
            resources :imports, only: [:new, :create] do
              get :example, on: :collection
            end
            resources :reminders, only: [:new, :create]
          end

          resources :moderations do
            member do
              put :unreport
              put :hide
              put :unhide
            end
            resources :reports, controller: "moderations/reports", only: [:index, :show]
          end

          resources :participatory_space_private_users, controller: "participatory_space_private_users" do
            member do
              post :resend_invitation, to: "participatory_space_private_users#resend_invitation"
            end
            collection do
              resource :participatory_space_private_users_csv_imports, only: [:new, :create], path: "csv_import" do
                delete :destroy_all
              end
            end
          end
        end

        scope "/assemblies/:assembly_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_assembly_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_assemblies.action_controller" do |app|
        app.config.to_prepare do
          ActiveSupport.on_load :action_controller do
            helper Decidim::Assemblies::Admin::AssembliesAdminMenuHelper if respond_to?(:helper)
          end
        end
      end

      initializer "decidim_assemblies.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :assemblies,
                        I18n.t("menu.assemblies", scope: "decidim.admin"),
                        decidim_admin_assemblies.assemblies_path,
                        icon_name: "dial",
                        position: 2.2,
                        active: :inclusive,
                        if: allowed_to?(:enter, :space_area, space_name: :assemblies)
        end
      end

      initializer "decidim_assemblies.assemblies_admin_attachments_menu" do
        Decidim.menu :assemblies_admin_attachments_menu do |menu|
          menu.add_item :assembly_attachment_collections,
                        I18n.t("attachment_collections", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.assembly_attachment_collections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.assembly_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection, assembly: current_participatory_space)

          menu.add_item :assembly_attachments,
                        I18n.t("attachment_files", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.assembly_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.assembly_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment, assembly: current_participatory_space)
        end
      end
      initializer "decidim_assemblies.admin_assemblies_components_menu" do
        Decidim.menu :admin_assemblies_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = translated_attribute(component.name)
            if component.primary_stat.present?
              caption += content_tag(:span, component.primary_stat, class: component.primary_stat.zero? ? "component-counter component-counter--off" : "component-counter")
            end

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)) ||
                                  is_active_link?(decidim_admin_assemblies.edit_component_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_assemblies.edit_component_permissions_path(current_participatory_space, component)) ||
                                  participatory_space_active_link?(component),
                          if: component.manifest.admin_engine && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end
      initializer "decidim_assemblies.assemblies_admin_menu" do
        Decidim.menu :admin_assembly_menu do |menu|
          menu.add_item :edit_assembly,
                        I18n.t("info", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.edit_assembly_path(current_participatory_space),
                        position: 1,
                        if: allowed_to?(:update, :assembly, assembly: current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.edit_assembly_path(current_participatory_space))

          menu.add_item :components,
                        I18n.t("components", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.components_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.components_path(current_participatory_space)),
                        if: allowed_to?(:read, :component, assembly: current_participatory_space),
                        submenu: { target_menu: :admin_assemblies_components_menu, options: { container_options: { id: "components-list" } } }

          menu.add_item :categories,
                        I18n.t("categories", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.categories_path(current_participatory_space),
                        if: allowed_to?(:read, :category, assembly: current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.categories_path(current_participatory_space))

          menu.add_item :attachments,
                        I18n.t("attachments", scope: "decidim.admin.menu.assemblies_submenu"),
                        "#",
                        active: is_active_link?(decidim_admin_assemblies.assembly_attachment_collections_path(current_participatory_space)) ||
                                is_active_link?(decidim_admin_assemblies.assembly_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection, assembly: current_participatory_space) ||
                            allowed_to?(:read, :attachment, assembly: current_participatory_space),
                        submenu: { target_menu: :assemblies_admin_attachments_menu }

          menu.add_item :assembly_members,
                        I18n.t("assembly_members", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.assembly_members_path(current_participatory_space),
                        if: allowed_to?(:read, :assembly_member, assembly: current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.assembly_members_path(current_participatory_space))

          menu.add_item :assembly_user_roles,
                        I18n.t("assembly_admins", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.assembly_user_roles_path(current_participatory_space),
                        if: allowed_to?(:read, :assembly_user_role, assembly: current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.assembly_user_roles_path(current_participatory_space))

          menu.add_item :participatory_space_private_users,
                        I18n.t("private_users", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.participatory_space_private_users_path(current_participatory_space),
                        if: allowed_to?(:read, :space_private_user, assembly: current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.participatory_space_private_users_path(current_participatory_space))

          menu.add_item :moderations,
                        I18n.t("moderations", scope: "decidim.admin.menu.assemblies_submenu"),
                        decidim_admin_assemblies.moderations_path(current_participatory_space),
                        if: allowed_to?(:read, :moderation, assembly: current_participatory_space),
                        active: is_active_link?(decidim_admin_assemblies.moderations_path(current_participatory_space))
        end
      end
      initializer "decidim_assemblies.admin_assemblies_menu" do
        Decidim.menu :admin_assemblies_menu do |menu|
          menu.add_item :assemblies,
                        I18n.t("menu.assemblies", scope: "decidim.admin"),
                        decidim_admin_assemblies.assemblies_path,
                        position: 1.0,
                        active: is_active_link?(decidim_admin_assemblies.assemblies_path),
                        if: allowed_to?(:read, :assembly_list)

          menu.add_item :assemblies_types,
                        I18n.t("menu.assemblies_types", scope: "decidim.admin"),
                        decidim_admin_assemblies.assemblies_types_path,
                        active: is_active_link?(decidim_admin_assemblies.assemblies_types_path),
                        position: 1.1,
                        if: allowed_to?(:manage, :assemblies_type)

          menu.add_item :edit_assemblies_settings,
                        I18n.t("menu.assemblies_settings", scope: "decidim.admin"),
                        decidim_admin_assemblies.edit_assemblies_settings_path,
                        active: is_active_link?(decidim_admin_assemblies.edit_assemblies_settings_path),
                        position: 1.3,
                        if: allowed_to?(:read, :assemblies_setting)
        end
      end
    end
  end
end
