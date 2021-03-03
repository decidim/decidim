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
      paths["lib/tasks"] = nil

      routes do
        resources :initiatives_types, except: :show do
          resource :permissions, controller: "initiatives_types_permissions"
          resources :initiatives_type_scopes, except: [:index, :show]
        end

        resources :initiatives, only: [:index, :show, :edit, :update], param: :slug do
          member do
            get :send_to_technical_validation
            post :publish
            delete :unpublish
            delete :discard
            get :export_votes
            get :export_pdf_signatures
            post :accept
            delete :reject
          end

          collection do
            get :export
          end

          resources :attachments, controller: "initiative_attachments"

          resources :committee_requests, only: [:index] do
            member do
              get :approve
              delete :revoke
            end
          end

          resource :answer, only: [:edit, :update]
        end

        scope "/initiatives/:initiative_slug" do
          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
              get :share
            end
            resources :exports, only: :create
          end

          resources :moderations do
            member do
              put :unreport
              put :hide
              put :unhide
            end
            resources :reports, controller: "moderations/reports", only: [:index, :show]
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

      initializer "admin_decidim_initiatives.action_controller" do |_app|
        ActiveSupport.on_load :action_controller do
          helper Decidim::Initiatives::Admin::InitiativeAdminMenuHelper if respond_to?(:helper)
        end
      end

      initializer "decidim_initiaves.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.initiatives", scope: "decidim.admin"),
                    decidim_admin_initiatives.initiatives_path,
                    icon_name: "chat",
                    position: 2.4,
                    active: :inclusive,
                    if: allowed_to?(:enter, :space_area, space_name: :initiatives)
        end
      end

      initializer "admin_decidim_initiatives.admin_menu" do
        Decidim.menu :admin_initiatives_menu do |menu|
          menu.item I18n.t("menu.initiatives", scope: "decidim.admin"),
                    decidim_admin_initiatives.initiatives_path,
                    position: 1.0,
                    active: is_active_link?(decidim_admin_initiatives.initiatives_path),
                    if: allowed_to?(:index, :initiative)

          menu.item I18n.t("menu.initiatives_types", scope: "decidim.admin"),
                    decidim_admin_initiatives.initiatives_types_path,
                    active: is_active_link?(decidim_admin_initiatives.initiatives_types_path),
                    if: allowed_to?(:manage, :initiative_type)
        end
      end
    end
  end
end
