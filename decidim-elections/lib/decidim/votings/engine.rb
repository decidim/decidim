# frozen_string_literal: true

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

      initializer "decidim_votings.register_icons" do
        Decidim.icons.register(name: "Decidim::Votings::Voting", icon: "check-double-fill", description: "Voting", category: "activity", resource: "core", engine: :votings)
        Decidim.icons.register(name: "lock-unlock-line", icon: "lock-unlock-line", resource: "core", category: "system", description: "", engine: :votings)
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
        Decidim.menu :menu do |menu|
          menu.add_item :votings,
                        I18n.t("menu.votings", scope: "decidim"),
                        decidim_votings.votings_path,
                        position: 2.6,
                        if: Decidim::Votings::Voting.where(organization: current_organization).published.any?,
                        active: :inclusive
        end

        Decidim.menu :home_content_block_menu do |menu|
          menu.add_item :votings,
                        I18n.t("menu.votings", scope: "decidim"),
                        decidim_votings.votings_path,
                        position: 40,
                        if: Decidim::Votings::Voting.where(organization: current_organization).published.any?,
                        active: :inclusive
        end
      end

      initializer "decidim_votings.content_blocks" do
        Decidim.content_blocks.register(:homepage, :highlighted_votings) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/highlighted_votings"
          content_block.public_name_key = "decidim.votings.content_blocks.highlighted_votings.name"
          content_block.settings_form_cell = "decidim/votings/content_blocks/highlighted_votings_settings_form"

          content_block.settings do |settings|
            settings.attribute :max_results, type: :integer, default: 4
          end
        end

        Decidim.content_blocks.register(:voting_landing_page, :hero) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/hero"
          content_block.settings_form_cell = "decidim/votings/content_blocks/hero_settings_form"
          content_block.public_name_key = "decidim.content_blocks.hero.name"

          content_block.settings do |settings|
            settings.attribute :button_text, type: :text, translated: true
            settings.attribute :button_url, type: :text, translated: true
          end

          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :title) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/main_data"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.main_data.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :related_elections) do |content_block|
          content_block.cell = "decidim/elections/content_blocks/related_elections"
          content_block.settings_form_cell = "decidim/content_blocks/highlighted_elements_for_component_settings_form"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.related_elections.name"
          content_block.component_manifest_name = "elections"

          content_block.settings do |settings|
            settings.attribute :component_id, type: :select, default: nil
          end
        end

        Decidim.content_blocks.register(:voting_landing_page, :polling_stations) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/polling_stations"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.polling_stations.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :stats) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/statistics"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.stats.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :metrics) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/metrics"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.metrics.name"
        end

        Decidim.content_blocks.register(:voting_landing_page, :html) do |content_block|
          content_block.cell = "decidim/content_blocks/html"
          content_block.public_name_key = "decidim.content_blocks.html.name"
          content_block.settings_form_cell = "decidim/content_blocks/html_settings_form"

          content_block.settings do |settings|
            settings.attribute :html_content, type: :text, translated: true
          end
        end

        Decidim.content_blocks.register(:voting_landing_page, :related_documents) do |content_block|
          content_block.cell = "decidim/content_blocks/participatory_space_documents"
          content_block.public_name_key = "decidim.application.documents.related_documents"
        end

        Decidim.content_blocks.register(:voting_landing_page, :related_images) do |content_block|
          content_block.cell = "decidim/content_blocks/participatory_space_images"
          content_block.public_name_key = "decidim.application.photos.related_photos"
        end
      end

      initializer "decidim_votings.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Votings::QueryExtensions
      end
    end
  end
end
