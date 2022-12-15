# frozen_string_literal: true

module Decidim
  module Debates
    # This cell renders metadata for an instance of a Meeting
    class DebateCardMetadataCell < Decidim::CardMetadataCell
      include Decidim::LayoutHelper
      include ActionView::Helpers::DateHelper

      alias debate model

      delegate :start_time, :end_time, to: :debate

      def initialize(*)
        super

        @items.prepend(*debate_items)
      end

      def debate_items
        [duration]
      end

      def duration
        return if [start_time, end_time].any?(&:blank?)

        {
          text: distance_of_time_in_words(start_time, end_time, scope: "datetime.distance_in_words.short"),
          icon: "time-line"
        }
      end

    end
  end
end
