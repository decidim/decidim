# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders metadata for an instance of an Election
    class ElectionMetadataCell < Decidim::CardMetadataCell
      def initialize(*)
        super

        @items.prepend(*election_items)
      end

      private

      def election_items
        [dates_metadata_item, state_item]
      end

      def state_item
        return if model.voting_period_status.blank?

        { text: content_tag(:span, I18n.t(model.voting_period_status, scope: "decidim.elections.election_m.badge_name"), class: "label #{state_class}") }
      end

      def state_class
        case model.voting_period_status
        when :ongoing
          "success"
        when :upcoming
          "warning"
        end
      end

      def start_date
        return unless model.start_time

        model.start_time.to_date
      end

      def end_date
        return unless model.end_time

        model.end_time.to_date
      end

      def dates_metadata_item
        {
          icon: "calendar-todo-line",
          text: [
            start_date.present? ? l(start_date, format: :decidim_short_with_month_name_short) : "?",
            end_date.present? ? l(end_date, format: :decidim_short_with_month_name_short) : "?"
          ].join(" → ")
        }
      end
    end
  end
end
