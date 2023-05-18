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
          text: data_with_text(proposals_count, t("decidim.sortitions.sortitions.sortition.selected_proposals", count: proposals_count)),
          icon: "chat-new-line"
        }
      end

      def seed_item
        {
          text: data_with_text(model.seed, t("random_seed", scope: "decidim.sortitions.sortitions.sortition")),
          icon: "seedling-line"
        }
      end

      def badge_item
        {
          text: content_tag(:span, class: "label #{state_classes}") { badge_name }
        }
      end

      def has_badge?
        false
      end

      def badge_name
        return t("filters.cancelled", scope: "decidim.sortitions.sortitions") if model.cancelled?

        t("filters.active", scope: "decidim.sortitions.sortitions")
      end

      def data_with_text(data, text)
        "#{content_tag(:strong) { data }}#{content_tag(:span) { text }}".html_safe
      end

      def state_classes
        return "alert" if model.cancelled?

        "success"
      end

      def proposals_count
        @proposals_count = model.proposals.count
      end
    end
  end
end
