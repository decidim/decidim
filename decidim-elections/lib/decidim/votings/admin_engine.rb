# frozen_string_literal: true

require "decidim/votings/menu"

module Decidim
  module Votings
    # Decidim's Votings Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Votings::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :votings, param: :slug do
          resource :publish, controller: "voting_publications", only: [:create, :destroy]
          member do
            get :available_polling_officers
          end

          resource :landing_page, only: [:edit, :update], controller: "votings_landing_page" do
            resources :content_blocks, only: [:edit, :update, :destroy, :create], controller: "votings_landing_page_content_blocks"
          end

          resources :polling_stations
          resources :polling_officers, only: [:new, :create, :destroy, :index]
          resources :monitoring_committee_members, only: [:new, :create, :destroy, :index]
          resources :monitoring_committee_polling_station_closures, only: [:index, :edit, :show] do
            post :validate, on: :member
          end
          resources :monitoring_committee_verify_elections, only: [:index]
          resources :monitoring_committee_election_results, only: [:index, :show, :update]
          resources :attachments, controller: "voting_attachments", except: [:show]
          resources :attachment_collections, controller: "voting_attachment_collections", except: [:show]
          resources :ballot_styles

          resource :census, only: [:show, :destroy, :create], controller: "/decidim/votings/census/admin/census" do
            member do
              get :status
              get :generate_access_codes
              get :export_access_codes
              get :download_access_codes_file
            end
          end
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
            resources :imports, only: [:new, :create] do
              get :example, on: :collection
            end
            resources :reminders, only: [:new, :create]
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

      initializer "decidim_votings_admin.menu" do
        Decidim::Votings::Menu.register_admin_menu_modules!
      end

      initializer "decidim_votings_admin.votings_components_menu" do
        Decidim::Votings::Menu.register_admin_votings_components_menu!
      end

      initializer "decidim_votings_admin.attachments_menu" do
        Decidim::Votings::Menu.register_votings_admin_attachments_menu!
      end

      initializer "decidim_votings_admin.monitoring_committee_menu" do
        Decidim::Votings::Menu.register_decidim_votings_monitoring_committee_menu!
      end

      initializer "decidim_votings_admin.voting_menu" do
        Decidim::Votings::Menu.register_admin_voting_menu!
      end
    end
  end
end
