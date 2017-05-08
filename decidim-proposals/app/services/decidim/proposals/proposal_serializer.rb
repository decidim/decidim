# frozen_string_literal: true

module Decidim
  module Proposals
    # This class serializes a Proposal so can be exported to CSV, JSON or other
    # formats.
    class ProposalSerializer
      include Rails.application.routes.url_helpers

      # Public: Initializes the serializer with a proposal.
      def initialize(proposal)
        @proposal = proposal
      end

      # Public: Exports a hash with the serialized data for this proposal.
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
          meeting_urls: meetings
        }
      end

      private

      attr_reader :proposal

      def feature
        proposal.feature
      end

      def organization
        feature.organization
      end

      def meetings
        @proposal.linked_resources(:meetings, "proposals_from_meeting").map do |meeting|
          Decidim::Meetings::ListEngine.routes.url_helpers.meeting_url(
            meeting,
            feature_id: feature,
            participatory_process_id: participatory_process,
            host: organization.host
          )
        end
      end

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
