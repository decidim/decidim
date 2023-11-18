# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Core
    module ContentBlocks
      class RegistryManager
        def self.register_homepage_content_blocks!
          Decidim.content_blocks.register(:homepage, :hero) do |content_block|
            content_block.cell = "decidim/content_blocks/hero"
            content_block.settings_form_cell = "decidim/content_blocks/hero_settings_form"
            content_block.public_name_key = "decidim.content_blocks.hero.name"

            content_block.images = [
              {
                name: :background_image,
                uploader: "Decidim::HomepageImageUploader"
              }
            ]

            content_block.settings do |settings|
              settings.attribute :welcome_text, type: :text, translated: true
            end

            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :global_menu) do |content_block|
            content_block.cell = "decidim/content_blocks/global_menu"
            content_block.public_name_key = "decidim.content_blocks.global_menu.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :sub_hero) do |content_block|
            content_block.cell = "decidim/content_blocks/sub_hero"
            content_block.public_name_key = "decidim.content_blocks.sub_hero.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :highlighted_content_banner) do |content_block|
            content_block.cell = "decidim/content_blocks/highlighted_content_banner"
            content_block.public_name_key = "decidim.content_blocks.highlighted_content_banner.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :how_to_participate) do |content_block|
            content_block.cell = "decidim/content_blocks/how_to_participate"
            content_block.public_name_key = "decidim.content_blocks.how_to_participate.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :last_activity) do |content_block|
            content_block.cell = "decidim/content_blocks/last_activity"
            content_block.public_name_key = "decidim.content_blocks.last_activity.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :stats) do |content_block|
            content_block.cell = "decidim/content_blocks/stats"
            content_block.public_name_key = "decidim.content_blocks.stats.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :metrics) do |content_block|
            content_block.cell = "decidim/content_blocks/organization_metrics"
            content_block.public_name_key = "decidim.content_blocks.metrics.name"
          end

          Decidim.content_blocks.register(:homepage, :footer_sub_hero) do |content_block|
            content_block.cell = "decidim/content_blocks/footer_sub_hero"
            content_block.public_name_key = "decidim.content_blocks.footer_sub_hero.name"
            content_block.default!
          end

          Decidim.content_blocks.register(:homepage, :html) do |content_block|
            content_block.cell = "decidim/content_blocks/html"
            content_block.public_name_key = "decidim.content_blocks.html.name"
            content_block.settings_form_cell = "decidim/content_blocks/html_settings_form"

            content_block.settings do |settings|
              settings.attribute :html_content, type: :text, translated: true
            end
          end
        end
      end
    end
  end
end
