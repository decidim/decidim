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
        resources :assemblies do
          resource :publish, controller: "assembly_publications", only: [:create, :destroy]
          resources :copies, controller: "assembly_copies", only: [:new, :create]

          resources :attachments, controller: "assembly_attachments"
        end

        scope "/assemblies/:assembly_id" do
          resources :categories

          resources :features do
            resource :permissions, controller: "feature_permissions"
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
        end

        scope "/assemblies/:assembly_id/features/:feature_id/manage" do
          Decidim.feature_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentFeature.new(manifest) do
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
            "Decidim::Assemblies::Abilities::Admin::AdminAbility"
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
                    if: can?(:manage, Decidim::Assembly)
        end
      end
    end
  end
end
