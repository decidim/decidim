# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell renders metadata for an instance of a Proposal
    class ProposalCardMetadataCell < Decidim::CardMetadataCell
      def initialize(*)
        super

        @items.prepend(*proposal_items)
      end

      private

      def proposal_items
        [coauthors_item, comments_count_item, endorsements_count_item]
      end
    end
  end
end
