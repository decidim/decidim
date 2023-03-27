# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell renders metadata for an instance of a Proposal
    class ProposalMetadataGCell < ProposalMetadataCell
      private

      def proposal_items
        [coauthors_item, state_item]
      end
    end
  end
end
