# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalSerializer
      include Rails.application.routes.url_helpers

      def initialize(proposal)
        @proposal = proposal
      end

      def serialize
        {
          id: @proposal.id,
          category: {
            id: @proposal.category.try(:id),
            name: @proposal.category.try(:name)
          },
          title: @proposal.title,
          body: @proposal.body,
          votes: @proposal.proposal_votes_count,
          comments: @proposal.comments.count,
          created_at: @proposal.created_at,
          url: url,
          feature: { id: feature.id },
          meeting_ids: @proposal.linked_resources(:meetings, "proposals_from_meeting").pluck(:id)
        }
      end

      private

      def feature
        proposal.feature
      end

      def organization
        feature.organization
      end

      attr_reader :proposal

      def participatory_process
        feature.participatory_process
      end

      def url
        Decidim::Proposals::Engine.routes.url_helpers.proposal_url(
          proposal,
          feature_id: feature,
          participatory_process_id: participatory_process,
          host: organization.host
        )
      end
    end
  end
end
