# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

require "decidim/conferences/query_extensions"
require "decidim/conferences/content_blocks/registry_manager"
require "decidim/conferences/menu"

module Decidim
  module Conferences
    # Decidim's Conferences Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Conferences

      routes do
        get "conferences/:conference_id", to: redirect { |params, _request|
          conference = Decidim::Conference.find(params[:conference_id])
          conference ? "/conferences/#{conference.slug}" : "/404"
        }, constraints: { conference_id: /[0-9]+/ }

        get "/conferences/:conference_id/f/:component_id", to: redirect { |params, _request|
          conference = Decidim::Conferences.find(params[:conference_id])
          conference ? "/conferences/#{conference.slug}/f/#{params[:component_id]}" : "/404"
        }, constraints: { conference_id: /[0-9]+/ }

        resources :conferences, only: [:index, :show], param: :slug, path: "conferences" do
          get :user, to: "conferences#user_diploma"
          resources :conference_speakers, only: :index, path: "speakers"
          resources :conference_program, only: :show, path: "program"
          resources :registration_types, only: :index, path: "registration" do
            resource :conference_registration, only: [:create, :destroy] do
              collection do
                get :create
                get :decline_invitation
              end
            end
          end
          resources :media, only: :index
        end
        scope "/conferences/:conference_slug/f/:component_id" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.engine, at: "/", as: "decidim_conference_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_conferences.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Conferences::Engine, at: "/", as: "decidim_conferences"
        end
      end

      initializer "decidim_conferences.register_icons" do
        Decidim.icons.register(name: "Decidim::Conference", icon: "mic-line", description: "Conference", category: "activity", engine: :conferences)
        Decidim.icons.register(name: "conference_speaker", icon: "user-voice-line", description: "Speaker", category: "conferences", engine: :conferences)

        Decidim.icons.register(name: "film-line", icon: "film-line", category: "system", description: "", engine: :conferences)
        Decidim.icons.register(name: "ticket-line", icon: "ticket-line", category: "system", description: "", engine: :conferences)
        Decidim.icons.register(name: "link-m", icon: "link-m", category: "system", description: "", engine: :conferences)
      end

      initializer "decidim_conferences.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Conferences::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Conferences::Engine.root}/app/views") # for partials
      end

      initializer "decidim_conferences.stats" do
        Decidim.stats.register :conferences_count,
                               priority: StatsRegistry::HIGH_PRIORITY,
                               icon_name: "user-voice-line",
                               tooltip_key: "conferences_count_tooltip" do |organization, _start_at, _end_at|
          Decidim::Conference.where(organization:).public_spaces.count
        end
      end

      initializer "decidim_conferences.menu" do
        Decidim::Conferences::Menu.register_menu!
        Decidim::Conferences::Menu.register_mobile_menu!
        Decidim::Conferences::Menu.register_home_content_block_menu!
      end

      initializer "decidim_conferences.content_blocks" do
        Decidim::Conferences::ContentBlocks::RegistryManager.register!
      end

      initializer "decidim_conferences.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Conferences::QueryExtensions
      end

      initializer "decidim_conferences.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
