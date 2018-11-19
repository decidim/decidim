# frozen_string_literal: true

module Decidim
  module Proposals
    module Metrics
      # Searches for Participants in the following actions
      #  - Create a proposal (Proposals)
      #  - Give support to a proposal (Proposals)
      #  - Endorse (Proposals)
      class ProposalParticipantsMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          cumulative_users = []
          cumulative_users |= retreive_votes.pluck(:decidim_author_id)
          cumulative_users |= retreive_endorsements.pluck(:decidim_author_id)
          cumulative_users |= retreive_proposals.pluck("decidim_coauthorships.decidim_author_id") # To avoid ambiguosity must be called this way

          quantity_users = []
          quantity_users |= retreive_votes(true).pluck(:decidim_author_id)
          quantity_users |= retreive_endorsements(true).pluck(:decidim_author_id)
          quantity_users |= retreive_proposals(true).pluck("decidim_coauthorships.decidim_author_id") # To avoid ambiguosity must be called this way

          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end

        private

        def retreive_proposals(from_start = false)
          @proposals ||= Decidim::Proposals::Proposal.where(component: @resource).joins(:coauthorships)
                                                     .includes(:votes, :endorsements)
                                                     .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
                                                     .where("decidim_proposals_proposals.published_at <= ?", end_time)
                                                     .except_withdrawn

          return @proposals.where("decidim_proposals_proposals.published_at >= ?", start_time) if from_start
          @proposals
        end

        def retreive_votes(from_start = false)
          @votes ||= Decidim::Proposals::ProposalVote.joins(:proposal).where(proposal: retreive_proposals).joins(:author)
                                                     .where("decidim_proposals_proposal_votes.created_at <= ?", end_time)

          return @votes.where("decidim_proposals_proposal_votes.created_at >= ?", start_time) if from_start
          @votes
        end

        def retreive_endorsements(from_start = false)
          @endorsements ||= Decidim::Proposals::ProposalEndorsement.joins(:proposal).where(proposal: retreive_proposals)
                                                                   .where("decidim_proposals_proposal_endorsements.created_at <= ?", end_time)
                                                                   .where(decidim_author_type: "Decidim::UserBaseEntity")

          return @endorsements.where("decidim_proposals_proposal_endorsements.created_at >= ?", start_time) if from_start
          @endorsements
        end
      end
    end
  end
end
