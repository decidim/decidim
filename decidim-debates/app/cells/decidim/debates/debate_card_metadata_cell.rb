# frozen_string_literal: true

module Decidim
  module Debates
    # This cell renders metadata for an instance of a Meeting
    class DebateCardMetadataCell < Decidim::CardMetadataCell
      include Decidim::LayoutHelper
      include ActionView::Helpers::DateHelper

      alias debate model

      delegate :type_of_meeting, :start_time, :end_time, :withdrawn?, to: :debate

      def initialize(*)
        super

        @items.prepend(*debate_items)
      end

      def debate_items
        [duration, comments_count_item, likes_count_item] + taxonomy_items + [coauthors_item]
      end

      def duration
        text = format_date_range(debate.start_time, debate.end_time) || t("open", scope: "decidim.debates.debates.show")

        {
          text:,
          icon: "time-line"
        }
      end
    end
  end
end
