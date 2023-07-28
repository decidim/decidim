# frozen_string_literal: true

module Decidim
  module Votings
    # This cell renders metadata for an instance of a Voting
    class VotingMetadataCell < Decidim::CardMetadataCell
      delegate :voting_type, :period_status, :start_time, :end_time, to: :model

      def initialize(*)
        super

        @items.prepend(*voting_items)
      end

      private

      def voting_items
        [dates_metadata_item, type_item, status_item]
      end

      def type_item
        {
          icon: resource_type_icon_key(voting_type),
          text: t(voting_type, scope: "decidim.votings.votings_m.voting_type")
        }
      end

      def status_item
        return if period_status.blank?

        { text: content_tag(:span, t(period_status, scope: "decidim.votings.votings_m.badge_name"), class: "label #{state_class}") }
      end

      def state_class
        case period_status
        when :ongoing
          "success"
        when :upcoming
          "warning"
        end
      end

      def start_date
        return unless start_time

        start_time.to_date
      end

      def end_date
        return unless end_time

        end_time.to_date
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
