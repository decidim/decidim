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
        end

        scope "/assemblies/:assembly_slug" do
          resources :categories

          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
            end
            resources :exports, only: :create
          end

          resources :moderations do
            member do
              put :unreport
              put :hide
              put :unhide
            end
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

      initializer "decidim_assemblies.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_assemblies_manifest.js)
      end

      initializer "decidim_assemblies.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.assemblies", scope: "decidim.admin"),
                    decidim_admin_assemblies.assemblies_path,
                    icon_name: "dial",
                    position: 3.5,
                    active: :inclusive,
                    if: allowed_to?(:enter, :space_area, space_name: :assemblies)
        end
      end
    end
  end
end
