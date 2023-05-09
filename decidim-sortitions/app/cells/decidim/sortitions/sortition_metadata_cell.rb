# frozen_string_literal: true

module Decidim
  module Sortitions
    # This cell renders the assembly metadata for l card
    class SortitionMetadataCell < Decidim::CardMetadataCell
      include Decidim::Sortitions::SortitionsHelper

      delegate :state, to: :model

      def initialize(*)
        super

        @items.prepend(*sortition_items)
      end

      def sortition_items
        [count_item, seed_item, badge_item]
      end

      def count_item
        {
          text: "#{proposals_count} #{t("decidim.sortitions.sortitions.sortition.selected_proposals", count: proposals_count)}",
          icon: "chat-new-line"
        }
      end

      def seed_item
        {
          text: "#{t("decidim.sortitions.sortitions.sortition.random_seed")} #{model.seed}",
          icon: "seedling-line"
        }
      end

      #REDESIGN_PENDING: add a function to pass the status(alert, warning or success) as a class to the tag
      def badge_item
        {
          text: content_tag(:span, class: "alert label") {badge_name}
        }
      end

      def has_badge?
        false
      end

      def badge_name
        return t("filters.cancelled", scope: "decidim.sortitions.sortitions") if model.cancelled?

        t("filters.active", scope: "decidim.sortitions.sortitions")
      end

      def state_classes
        return ["muted"] if model.cancelled?

        ["success"]
      end

      def proposals_count
        @proposals_count = model.proposals.count
      end
    end
  end
end
