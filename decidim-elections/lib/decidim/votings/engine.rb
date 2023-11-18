# frozen_string_literal: true

require "decidim/votings/content_blocks/registry_manager"
require "decidim/votings/menu"
require "decidim/votings/query_extensions"

module Decidim
  module Votings
    # This is the engine that runs on the public interface for Votings of `decidim-elections`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Votings

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :votings, param: :slug, only: [:index, :show, :update] do
          get :check_census, action: :show_check_census
          post :check_census, action: :check_census
          match :login, via: [:get, :post]
          post :send_access_code
          get :elections_log
        end

        get "votings/:voting_id", to: redirect { |params, _request|
          voting = Decidim::Votings::Voting.find(params[:voting_id])
          voting ? "/votings/#{voting.slug}" : "/404"
        }, constraints: { voting_id: /[0-9]+/ }

        get "/votings/:voting_id/f/:component_id", to: redirect { |params, _request|
          voting = Decidim::Votings::Voting.find(params[:voting_id])
          voting ? "/votings/#{voting.slug}/f/#{params[:component_id]}" : "/404"
        }, constraints: { voting_id: /[0-9]+/ }

        scope "/votings/:voting_slug/f/:component_id" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.engine, at: "/", as: "decidim_voting_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_votings.stats" do
        Decidim.stats.register :votings_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, _start_at, _end_at|
          Decidim::Votings::Voting.where(organization:).published.count
        end
      end

      initializer "decidim_votings.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Votings::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Votings::Engine.root}/app/views") # for partials
      end

      initializer "decidim_votings.menu" do
        Decidim::Votings::Menu.register_menu!
        Decidim::Votings::Menu.register_home_content_block_menu!
      end

      initializer "decidim_votings.content_blocks" do
        Decidim::Votings::ContentBlocks::RegistryManager.register!
      end

      initializer "decidim_votings.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Votings::QueryExtensions
      end
    end
  end
end
