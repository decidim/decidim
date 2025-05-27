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
          text: content_tag("span", t(label_string, scope: "decidim.debates.debates.show"), class: "#{label_class} label")
        }
      end

      def label_string
        case debate.state
        when :ongoing
          "ongoing"
        when :not_started
          "not_started"
        else
          "closed"
        end
      end

      def label_class
        case debate.state
        when :ongoing
          "success"
        when :not_started
          "warning"
        else
          "alert"
        end
      end
    end
  end
end
