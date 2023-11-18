# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Initiatives
    module ContentBlocks
      class RegistryManager
        def self.register!
          Decidim.content_blocks.register(:homepage, :highlighted_initiatives) do |content_block|
            content_block.cell = "decidim/initiatives/content_blocks/highlighted_initiatives"
            content_block.public_name_key = "decidim.initiatives.content_blocks.highlighted_initiatives.name"
            content_block.settings_form_cell = "decidim/initiatives/content_blocks/highlighted_initiatives_settings_form"

            content_block.settings do |settings|
              settings.attribute :max_results, type: :integer, default: 4
              settings.attribute :order, type: :string, default: "default"
            end
          end
        end
      end
    end
  end
end
