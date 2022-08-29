# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"
require "wicked_pdf"

require "decidim/conferences/query_extensions"

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
          resource :conference_widget, only: :show, path: "embed"
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

      initializer "decidim_conferences.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Conferences::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Conferences::Engine.root}/app/views") # for partials
      end

      initializer "decidim.stats" do
        Decidim.stats.register :conferences_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, _start_at, _end_at|
          Decidim::Conference.where(organization:).public_spaces.count
        end
      end

      initializer "decidim_conferences.menu" do
        Decidim.menu :menu do |menu|
          menu.add_item :conferences,
                        I18n.t("menu.conferences", scope: "decidim"),
                        decidim_conferences.conferences_path,
                        position: 2.8,
                        if: Decidim::Conference.where(organization: current_organization).published.any?,
                        active: :inclusive
        end
      end

      initializer "decidim_conferences.content_blocks" do
        Decidim.content_blocks.register(:homepage, :highlighted_conferences) do |content_block|
          content_block.cell = "decidim/conferences/content_blocks/highlighted_conferences"
          content_block.public_name_key = "decidim.conferences.content_blocks.highlighted_conferences.name"
        end
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
