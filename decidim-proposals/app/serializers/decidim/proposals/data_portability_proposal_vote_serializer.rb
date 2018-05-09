# frozen_string_literal: true

module Decidim
  module Proposals
    class DataPortabilityProposalVoteSerializer < Decidim::Exporters::Serializer
      # Serializes a Proposal Vote for data portability
      def serialize
        {
          id: resource.id,
          proposal: {
            id: resource.proposal.id,
            title: resource.proposal.title,
            body: resource.proposal.body
          }
        }
      end
    end
  end
end
