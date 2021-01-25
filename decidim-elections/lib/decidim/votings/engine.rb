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
        resources :votings, param: :slug, only: [:index, :show, :update]
      end
      initializer "decidim_votings.assets" do |app|
        app.config.assets.precompile += %w(
          decidim_votings_manifest.js
          decidim_votings_manifest.css
        )
      end

      initializer "decidim.stats" do
        Decidim.stats.register :votings_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, _start_at, _end_at|
          Decidim::Votings::Voting.where(organization: organization).published.count
        end
      end

      initializer "decidim_votings.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Votings::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Votings::Engine.root}/app/views") # for partials
      end

      initializer "decidim_votings.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.votings", scope: "decidim"),
                    decidim_votings.votings_path,
                    position: 2.7,
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
      end

      initializer "decidim_votings.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Votings::QueryExtensions
        nil
      end
    end
  end
end
