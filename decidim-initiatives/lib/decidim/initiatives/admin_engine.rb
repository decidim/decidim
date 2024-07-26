# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"
require "decidim/initiatives/menu"

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

        resources :initiatives_settings, only: [:edit, :update], controller: "initiatives_settings"

        resources :initiatives, only: [:index, :edit, :update], param: :slug do
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

          resources :attachments, controller: "initiative_attachments", except: [:show]

          resources :committee_requests, only: [:index] do
            member do
              get :approve
              delete :revoke
            end
          end

          resource :permissions, controller: "initiatives_permissions"

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
            resources :component_share_tokens, except: [:show], path: "share_tokens", as: "share_tokens"
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

          resources :initiative_share_tokens, except: [:show], path: "share_tokens"
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

      initializer "decidim_initiatives_admin.menu" do
        Decidim::Initiatives::Menu.register_admin_menu_modules!
        Decidim::Initiatives::Menu.register_admin_initiatives_components_menu!
        Decidim::Initiatives::Menu.register_admin_initiative_menu!
        Decidim::Initiatives::Menu.register_admin_initiative_actions_menu!
        Decidim::Initiatives::Menu.register_admin_initiatives_menu!
      end
    end
  end
end
