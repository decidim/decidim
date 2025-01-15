# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"
require "decidim/conferences/menu"

module Decidim
  module Conferences
    # Decidim's Conferences Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Conferences::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
          resources :conference_filters, except: [:show]

          resources :conferences, param: :slug, except: [:show, :destroy] do
            resource :publish, controller: "conference_publications", only: [:create, :destroy]
            resources :copies, controller: "conference_copies", only: [:new, :create]
            resources :speakers, controller: "conference_speakers" do
              member do
                put :publish
                put :unpublish
              end
            end
            resources :partners, controller: "partners", except: [:show]
            resources :media_links, controller: "media_links"
            resources :registration_types, controller: "registration_types" do
              resource :publish, controller: "registration_type_publications", only: [:create, :destroy]
              collection do
                get :conference_meetings
              end
            end
            resources :conference_invites, only: [:index, :new, :create]
            resources :conference_registrations, only: :index do
              member do
                post :confirm
              end
              collection do
                get :export
              end
            end
            resource :diploma, only: [:edit, :update] do
              member do
                post :send, to: "diplomas#send_diplomas"
              end
            end
            resources :user_roles, controller: "conference_user_roles" do
              member do
                post :resend_invitation, to: "conference_user_roles#resend_invitation"
              end
            end

            member do
              patch :soft_delete
              patch :restore
            end

            collection do
              get :manage_trash, to: "conferences#manage_trash"
            end

            resources :attachment_collections, controller: "conference_attachment_collections", except: [:show]
            resources :attachments, controller: "conference_attachments", except: [:show]
          end

          scope "/conferences/:conference_slug" do
            resources :components do
              collection do
                put :reorder
              end
              resource :permissions, controller: "component_permissions"
              member do
                put :publish
                put :unpublish
                get :share
                patch :soft_delete
                patch :restore
              end
              collection do
                get :manage_trash, to: "components#manage_trash"
                put :hide
              end
              resources :component_share_tokens, except: [:show], path: "share_tokens", as: "share_tokens"
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
              patch :bulk_action, on: :collection
              resources :reports, controller: "moderations/reports", only: [:index, :show]
            end

            resources :conference_share_tokens, except: [:show], path: "share_tokens"
          end

          scope "/conferences/:conference_slug/components/:component_id/manage" do
            Decidim.component_manifests.each do |manifest|
              next unless manifest.admin_engine

              constraints CurrentComponent.new(manifest) do
                mount manifest.admin_engine, at: "/", as: "decidim_admin_conference_#{manifest.name}"
              end
            end
          end
        end
      end

      initializer "decidim_conferences_admin.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Conferences::AdminEngine, at: "/admin", as: "decidim_admin_conferences"
        end
      end

      initializer "decidim_conferences_admin.menu" do
        Decidim::Conferences::Menu.register_admin_conferences_components_menu!
        Decidim::Conferences::Menu.register_conferences_admin_registrations_menu!
        Decidim::Conferences::Menu.register_conferences_admin_attachments_menu!
        Decidim::Conferences::Menu.register_conference_admin_menu!
        Decidim::Conferences::Menu.register_conferences_admin_menu!
        Decidim::Conferences::Menu.register_admin_menu_modules!
      end
    end
  end
end
