# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Votings
    module ContentBlocks
      class RegistryManager
        def self.register!
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
      end
    end
  end
end
