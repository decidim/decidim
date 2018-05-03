# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

module Decidim
  module Initiatives
    # Decidim's Assemblies Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Initiatives::Admin

      paths["db/migrate"] = nil

      routes do
        resources :initiatives_types, except: :show do
          resources :initiatives_type_scopes, except: [:index, :show]
        end

        resources :initiatives, only: [:index, :show, :edit, :update], param: :slug do
          member do
            get :send_to_technical_validation
            post :publish
            delete :unpublish
            delete :discard
            get :export_votes
            post :accept
            delete :reject
          end

          resources :attachments, controller: "initiative_attachments"

          resources :committee_requests, only: [:index] do
            member do
              get :approve
              delete :revoke
            end
          end
        end

        scope "/initiatives/:initiative_slug" do
          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
            end
            resources :exports, only: :create
          end
        end

        scope "/initiatives/:initiative_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_initiative_#{manifest.name}"
            end
          end
        end
      end

      initializer "admin_decidim_initiatives.assets" do |app|
        app.config.assets.precompile += %w(
          admin_decidim_initiatives_manifest.js
        )
      end

      initializer "decidim_assemblies.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.initiatives", scope: "decidim.admin"),
                    decidim_admin_initiatives.initiatives_path,
                    icon_name: "chat",
                    position: 3.7,
                    active: :inclusive,
                    if: allowed_to?(:enter, :space_area, space_name: :initiatives)
        end
      end
    end
  end
end
