# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Meetings
    module ContentBlocks
      class RegistryManager
        def self.register!
          Decidim.content_blocks.register(:homepage, :upcoming_meetings) do |content_block|
            content_block.cell = "decidim/meetings/content_blocks/highlighted_meetings"
            content_block.public_name_key = "decidim.meetings.content_blocks.upcoming_meetings.name"
            content_block.default!
          end
        end
      end
    end
  end
end
