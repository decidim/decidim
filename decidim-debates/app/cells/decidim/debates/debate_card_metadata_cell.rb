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
        [label, duration, comments_count_item, likes_count_item] + taxonomy_items + [coauthors_item]
      end

      def duration
        text = format_date_range(debate.start_time, debate.end_time)
        return if text.blank?

        {
          text:,
          icon: "time-line"
        }
      end

      def label
        {
          text: content_tag("span", t((debate.closed? ? "debate_closed" : "open"), scope: "decidim.debates.debates.show"), class: "#{debate.closed? ? "alert" : "success"} label")
        }
      end
    end
  end
end
