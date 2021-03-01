# frozen_string_literal: true

module Decidim
  module Votings
    # Decidim's Votings Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Votings::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :votings, param: :slug do
          member do
            put :publish
            put :unpublish
            get :available_polling_officers
            get :polling_officers_picker
          end

          resource :landing_page, only: [:edit, :update], controller: "votings_landing_page" do
            resources :content_blocks, only: [:edit, :update], controller: "votings_landing_page_content_blocks"
          end

          resources :polling_stations
          resources :polling_officers, only: [:new, :create, :destroy, :index]
          resources :monitoring_committee_members, only: [:new, :create, :destroy, :index]
          resources :attachments, controller: "voting_attachments"
          resources :attachment_collections, controller: "voting_attachment_collections"
        end

        scope "/votings/:voting_slug" do
          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
              get :share
            end
            resources :exports, only: :create
          end
        end

        scope "/votings/:voting_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_voting_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_votings.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.votings", scope: "decidim.votings.admin"),
                    decidim_admin_votings.votings_path,
                    icon_name: "comment-square",
                    position: 2.6,
                    active: :inclusive,
                    if: allowed_to?(:enter, :space_area, space_name: :votings)
        end
      end

      initializer "decidim_votings.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_votings_manifest.js admin/decidim_votings_manifest.css)
      end
    end
  end
end
