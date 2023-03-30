# frozen_string_literal: true

module Decidim
  module Debates
    # This cell renders metadata for an instance of a Meeting
    class DebateCardMetadataCell < Decidim::CardMetadataCell
      include Decidim::LayoutHelper
      include ActionView::Helpers::DateHelper

      alias debate model

      # REDESIGN PENDING: add new method to show calendar(start_time and end_time)
      delegate :type_of_meeting, :start_time, :end_time, :category, :withdrawn?, to: :debate

      def initialize(*)
        super

        @items.prepend(*debate_items)
      end

      def category_item
        return if category.blank?

        {
          text: category.translated_name,
          icon: resource_type_icon_key("Decidim::Category")
        }
      end

      def debate_items
        [duration, comments_count_item, endorsements_count_item, category_item, coauthors_item]
      end

      def duration
        text = if [start_time, end_time].any?(&:blank?)
                 t("decidim.debates.debates.show.open")
               else
                 distance_of_time_in_words(start_time, end_time, scope: "datetime.distance_in_words.short")
               end

        {
          text:,
          icon: "time-line"
        }
      end
    end
  end
end
