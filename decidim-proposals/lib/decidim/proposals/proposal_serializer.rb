# frozen_string_literal: true

module Decidim
  module Proposals
    # This class serializes a Proposal so can be exported to CSV, JSON or other
    # formats.
    class ProposalSerializer < Decidim::Proposals::OpenDataProposalSerializer
      # Public: Exports a hash with the serialized data for this proposal.
      def serialize
        super.merge({
                      votes: proposal.proposal_votes_count
                    })
      end
    end
  end
end
