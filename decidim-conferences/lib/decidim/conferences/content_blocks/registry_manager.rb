# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Conferences
    module ContentBlocks
      class RegistryManager
        def self.register!
        Decidim.content_blocks.register(:homepage, :highlighted_conferences) do |content_block|
          content_block.cell = "decidim/conferences/content_blocks/highlighted_conferences"
          content_block.public_name_key = "decidim.conferences.content_blocks.highlighted_conferences.name"
          content_block.settings_form_cell = "decidim/conferences/content_blocks/highlighted_conferences_settings_form"

          content_block.settings do |settings|
            settings.attribute :max_results, type: :integer, default: 6
          end
        end
        end
      end
    end
  end
end
