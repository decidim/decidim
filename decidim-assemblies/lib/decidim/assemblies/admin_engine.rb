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

      routes do
        resources :assemblies, param: :slug, except: :show do
          resource :publish, controller: "assembly_publications", only: [:create, :destroy]
          resources :copies, controller: "assembly_copies", only: [:new, :create]

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
            end
          end

          resources :participatory_space_private_users, controller: "participatory_space_private_users" do
            member do
              post :resend_invitation, to: "participatory_space_private_users#resend_invitation"
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

      initializer "decidim_assemblies.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            "Decidim::Assemblies::Abilities::Admin::AdminAbility",
            "Decidim::Assemblies::Abilities::Admin::AssemblyModeratorAbility",
            "Decidim::Assemblies::Abilities::Admin::AssemblyCollaboratorAbility",
            "Decidim::Assemblies::Abilities::Admin::AssemblyAdminAbility"
          ]
        end
      end

      initializer "decidim_assemblies.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.assemblies", scope: "decidim.admin"),
                    decidim_admin_assemblies.assemblies_path,
                    icon_name: "dial",
                    position: 3.5,
                    active: :inclusive,
                    if: can?(:read, Decidim::Assembly) &&
                        Decidim.find_participatory_space_manifest(:assemblies).space_for(current_organization).active?
        end
      end
    end
  end
end
