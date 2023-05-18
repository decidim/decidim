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
          text: count_text,
          icon: "chat-new-line"
        }
      end

      def seed_item
        {
          text: seed_text,
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

      def seed_text
        number = content_tag :strong do
          model.seed
        end

        text = content_tag :span do
          t("random_seed", scope: "decidim.sortitions.sortitions.sortition")
        end
        return number.concat(text)
      end

      def count_text
        number = content_tag :strong do
          proposals_count
        end

        text = content_tag :span do
          t("decidim.sortitions.sortitions.sortition.selected_proposals", count: proposals_count)
        end
        return number.concat(text)
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
