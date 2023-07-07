# frozen_string_literal: true

module Decidim
  module Votings
    # This cell renders metadata for an instance of a Proposal
    class VotingMetadataCell < Decidim::CardMetadataCell
      def initialize(*)
        super

        @items.prepend(*voting_items)
      end

      private

      def voting_items
        [dates_metadata_item, type_item]
      end

      def type_item
        {
          icon: resource_type_icon_key(model.voting_type),
          text: t(model.voting_type, scope: "decidim.votings.votings_m.voting_type"),
        }
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
