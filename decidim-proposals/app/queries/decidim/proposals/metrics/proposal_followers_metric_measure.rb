# frozen_string_literal: true

module Decidim
  module Proposals
    module Metrics
      # Searches for unique Users following the next objects
      #  - Proposals
      #  - CollaborativeDrafts
      class ProposalFollowersMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          cumulative_users = []
          cumulative_users |= retreive_proposals_followers.pluck(:decidim_user_id)
          cumulative_users |= retreive_drafts_followers.pluck(:decidim_user_id)

          quantity_users = []
          quantity_users |= retreive_proposals_followers(true).pluck(:decidim_user_id)
          quantity_users |= retreive_drafts_followers(true).pluck(:decidim_user_id)

          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end

        private

        def retreive_proposals_followers(from_start = false)
          @proposals_followers ||= Decidim::Follow.where(followable: retreive_proposals).joins(:user)
                                                  .where("decidim_follows.created_at <= ?", end_time)

          return @proposals_followers.where("decidim_follows.created_at >= ?", start_time) if from_start
          @proposals_followers
        end

        def retreive_drafts_followers(from_start = false)
          @drafts_followers ||= Decidim::Follow.where(followable: retreive_collaborative_drafts).joins(:user)
                                               .where("decidim_follows.created_at <= ?", end_time)
          return @drafts_followers.where("decidim_follows.created_at >= ?", start_time) if from_start
          @drafts_followers
        end

        def retreive_proposals
          Decidim::Proposals::Proposal.where(component: @resource).except_withdrawn
        end

        def retreive_collaborative_drafts
          Decidim::Proposals::CollaborativeDraft.where(component: @resource).except_withdrawn
        end
      end
    end
  end
end
