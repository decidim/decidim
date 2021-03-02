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
            resources :imports, only: [:new, :create]
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
              resource :participatory_space_private_users_csv_import, only: [:new, :create], path: "csv_import"
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

      initializer "decidim_assemblies.action_controller" do |_app|
        ActiveSupport.on_load :action_controller do
          helper Decidim::Assemblies::Admin::AssembliesAdminMenuHelper if respond_to?(:helper)
        end
      end

      initializer "decidim_assemblies.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_assemblies_manifest.js)
      end

      initializer "decidim_assemblies.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.assemblies", scope: "decidim.admin"),
                    decidim_admin_assemblies.assemblies_path,
                    icon_name: "dial",
                    position: 2.2,
                    active: :inclusive,
                    if: allowed_to?(:enter, :space_area, space_name: :assemblies)
        end
      end

      initializer "decidim_assemblies.admin_assemblies_menu" do
        Decidim.menu :admin_assemblies_menu do |menu|
          menu.item I18n.t("menu.assemblies", scope: "decidim.admin"),
                    decidim_admin_assemblies.assemblies_path,
                    position: 1.0,
                    active: is_active_link?(decidim_admin_assemblies.assemblies_path),
                    if: allowed_to?(:read, :assembly_list)

          menu.item I18n.t("menu.assemblies_types", scope: "decidim.admin"),
                    decidim_admin_assemblies.assemblies_types_path,
                    active: is_active_link?(decidim_admin_assemblies.assemblies_types_path),
                    position: 1.1,
                    if: allowed_to?(:manage, :assemblies_type)

          menu.item I18n.t("menu.assemblies_settings", scope: "decidim.admin"),
                    decidim_admin_assemblies.edit_assemblies_settings_path,
                    active: is_active_link?(decidim_admin_assemblies.edit_assemblies_settings_path),
                    position: 1.3,
                    if: allowed_to?(:read, :assemblies_setting)
        end
      end
    end
  end
end
