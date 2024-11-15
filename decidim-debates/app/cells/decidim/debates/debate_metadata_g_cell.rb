# frozen_string_literal: true

module Decidim
  module Debates
    # This cell renders metadata for an instance of a Debate
    class DebateMetadataGCell < Decidim::Debates::DebateCardMetadataCell
      private

      def debate_items
        [author_item, comments_count_item]
      end
    end
  end
end
