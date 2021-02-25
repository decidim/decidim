# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

module Decidim
  module Conferences
    # Decidim's Conferences Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Conferences::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :conferences, param: :slug, except: [:show, :destroy] do
          resource :publish, controller: "conference_publications", only: [:create, :destroy]
          resources :copies, controller: "conference_copies", only: [:new, :create]
          resources :speakers, controller: "conference_speakers"
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

          resources :attachment_collections, controller: "conference_attachment_collections"
          resources :attachments, controller: "conference_attachments"
        end

        scope "/conferences/:conference_slug" do
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

      initializer "decidim_conferences.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_conferences_manifest.js)
      end

      initializer "decidim_conferences.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.conferences", scope: "decidim.admin"),
                    decidim_admin_conferences.conferences_path,
                    icon_name: "microphone",
                    position: 2.8,
                    active: :inclusive,
                    if: allowed_to?(:enter, :space_area, space_name: :conferences)
        end
      end
    end
  end
end
