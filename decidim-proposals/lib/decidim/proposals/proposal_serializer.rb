# frozen_string_literal: true

module Decidim
  module Proposals
    # This class serializes a Proposal so can be exported to CSV, JSON or other
    # formats.
    class ProposalSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

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
          scope: {
            id: @proposal.scope.try(:id),
            name: @proposal.scope.try(:name)
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

      def meetings
        @proposal.linked_resources(:meetings, "proposals_from_meeting").map do |meeting|
          Decidim::ResourceLocatorPresenter.new(meeting).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(proposal).url
      end
    end
  end
end
