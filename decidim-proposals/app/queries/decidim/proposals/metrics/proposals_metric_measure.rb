# frozen_string_literal: true

module Decidim
  module Proposals
    module Metrics
      class ProposalsMetricMeasure < Decidim::MetricMeasure
        # Searches for Participants in the following actions
        #  Create a proposal (Proposals)
        #  Give support to a proposal (Proposals)
        #  Endorse (Proposals)

        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          proposals = Decidim::Proposals::Proposal.where(component: @resource).joins(:component)
                                                  .includes(:votes, :endorsements)
                                                  .except_withdrawn

          votes = Decidim::Proposals::ProposalVote.joins(:proposal).where(proposal: proposals)
                                                  .where("decidim_proposals_proposal_votes.created_at <= ?", end_time)
          endorsements = Decidim::Proposals::ProposalEndorsement.joins(:proposal).where(proposal: proposals)
                                                                .where("decidim_proposals_proposal_endorsements.created_at <= ?", end_time)
          proposals = proposals.where("decidim_proposals_proposals.published_at <= ?", end_time)

          cumulative_users = []
          cumulative_users |= votes.joins(:author).pluck(:decidim_author_id)
          cumulative_users |= endorsements.where(decidim_author_type: "Decidim::UserBaseEntity").pluck(:decidim_author_id)
          cumulative_users |= proposals.joins(:coauthorships)
                                       .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
                                       .pluck("decidim_coauthorships.decidim_author_id") # To avoid ambiguosity must be called this way

          votes = votes.where("decidim_proposals_proposal_votes.created_at >= ?", start_time)
          endorsements = endorsements.where("decidim_proposals_proposal_endorsements.created_at >= ?", start_time)
          proposals = proposals.where("decidim_proposals_proposals.published_at >= ?", start_time)

          quantity_users = []
          quantity_users |= votes.joins(:author).pluck(:decidim_author_id)
          quantity_users |= endorsements.where(decidim_author_type: "Decidim::UserBaseEntity").pluck(:decidim_author_id)
          quantity_users |= proposals.joins(:coauthorships)
                                     .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
                                     .pluck("decidim_coauthorships.decidim_author_id") # To avoid ambiguosity must be called this way

          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end
      end
    end
  end
end
