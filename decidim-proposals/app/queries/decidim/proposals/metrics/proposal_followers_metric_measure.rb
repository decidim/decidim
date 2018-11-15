# frozen_string_literal: true

module Decidim
  module Proposals
    module Metrics
      class ProposalFollowersMetricMeasure < Decidim::MetricMeasure
        # Searches for unique Users following the next objects
        #  - Proposals
        #  - CollaborativeDrafts

        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          proposals = Decidim::Proposals::Proposal.where(component: @resource).joins(:component)
                                                  .except_withdrawn
          collaborative_drafts = Decidim::Proposals::CollaborativeDraft.where(component: @resource).joins(:component).except_withdrawn

          proposals_followers = Decidim::Follow.where(followable: proposals).joins(:user)
                                               .where("decidim_follows.created_at <= ?", end_time)
          drafts_followers = Decidim::Follow.where(followable: collaborative_drafts).joins(:user)
                                            .where("decidim_follows.created_at <= ?", end_time)

          cumulative_users = []
          cumulative_users |= proposals_followers.pluck(:decidim_user_id)
          cumulative_users |= drafts_followers.pluck(:decidim_user_id)

          proposals_followers = proposals_followers.where("decidim_follows.created_at >= ?", start_time)
          drafts_followers = drafts_followers.where("decidim_follows.created_at >= ?", start_time)

          quantity_users = []
          quantity_users |= proposals_followers.pluck(:decidim_user_id)
          quantity_users |= drafts_followers.pluck(:decidim_user_id)

          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end
      end
    end
  end
end
