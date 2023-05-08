# frozen_string_literal: true

module Decidim
  module Sortitions
    # This cell renders the assembly metadata for l card
    class SortitionMetadataCell < Decidim::CardMetadataCell
      include Decidim::Sortitions::SortitionsHelper

      delegate :state, to: :model

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
