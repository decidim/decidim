# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

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
          # resources :conference_speakers, only: :index, path: "members"
          resource :conference_widget, only: :show, path: "embed"
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

      initializer "decidim_conferences.assets" do |app|
        app.config.assets.precompile += %w(decidim_conferences_manifest.js)
      end

      initializer "decidim_conferences.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Conferences::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Conferences::Engine.root}/app/views") # for partials
      end

      initializer "decidim.stats" do
        Decidim.stats.register :conferences_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, _start_at, _end_at|
          Decidim::Conference.where(organization: organization).public_spaces.count
        end
      end

      initializer "decidim_conferences.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.conferences", scope: "decidim"),
                    decidim_conferences.conferences_path,
                    position: 4,
                    if: Decidim::Conference.where(organization: current_organization).published.any?,
                    active: :inclusive
        end
      end

      initializer "decidim_conferences.view_hooks" do
        Decidim.view_hooks.register(:highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          highlighted_conferences = OrganizationPrioritizedConferences.new(view_context.current_organization, view_context.current_user)

          next unless highlighted_conferences.any?

          view_context.render(
            partial: "decidim/conferences/pages/home/highlighted_conferences",
            locals: {
              highlighted_conferences: highlighted_conferences
            }
          )
        end
      end
    end
  end
end
