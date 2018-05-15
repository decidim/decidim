# frozen_string_literal: true

module Decidim
  module Proposals
    class DataPortabilityProposalEndorsementSerializer < Decidim::Exporters::Serializer
      # Serializes a Proposal Endorsement for data portability
      def serialize
        {
          id: resource.id,
          proposal: {
            id: resource.proposal.id,
            title: resource.proposal.title,
            body: resource.proposal.body
          },
          user_group: {
            id: resource.try(:user_group).try(:id),
            name: resource.try(:user_group).try(:name)
          }
        }
      end
    end
  end
end
