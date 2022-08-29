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

      initializer "decidim.stats" do
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

        Decidim.content_blocks.register(:voting_landing_page, :header) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/landing_page/header"
          content_block.settings_form_cell = "decidim/votings/content_blocks/landing_page/header_settings_form"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.landing_page.header.name"

          content_block.settings do |settings|
            settings.attribute :button_text, type: :text, translated: true
            settings.attribute :button_url, type: :text, translated: true
          end
        end

        Decidim.content_blocks.register(:voting_landing_page, :description) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/landing_page/description"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.landing_page.description.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :elections) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/landing_page/elections"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.landing_page.elections.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :polling_stations) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/landing_page/polling_stations"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.landing_page.polling_stations.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :attachments_and_folders) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/landing_page/attachments_and_folders"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.landing_page.attachments_and_folders.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :stats) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/landing_page/statistics"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.landing_page.stats.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :metrics) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/landing_page/metrics"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.landing_page.metrics.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:voting_landing_page, :timeline) do |content_block|
          content_block.cell = "decidim/votings/content_blocks/landing_page/timeline"
          content_block.public_name_key = "decidim.votings.admin.content_blocks.landing_page.timeline.name"
          content_block.settings_form_cell = "decidim/content_blocks/html_settings_form"

          content_block.settings do |settings|
            settings.attribute :html_content, type: :text, translated: true
          end
        end

        1.upto(3) do |i|
          Decidim.content_blocks.register(:voting_landing_page, "html_block_#{i}".to_sym) do |content_block|
            content_block.cell = "decidim/content_blocks/html"
            content_block.public_name_key = "decidim.votings.admin.content_blocks.landing_page.html_block_#{i}.name"
            content_block.settings_form_cell = "decidim/content_blocks/html_settings_form"

            content_block.settings do |settings|
              settings.attribute :html_content, type: :text, translated: true
            end
          end
        end
      end

      initializer "decidim_votings.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Votings::QueryExtensions
      end
    end
  end
end
