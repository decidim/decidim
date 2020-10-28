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
          cumulative_users |= retrieve_proposals_followers.pluck(:decidim_user_id)
          cumulative_users |= retrieve_drafts_followers.pluck(:decidim_user_id)

          quantity_users = []
          quantity_users |= retrieve_proposals_followers(from_start: true).pluck(:decidim_user_id)
          quantity_users |= retrieve_drafts_followers(from_start: true).pluck(:decidim_user_id)

          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end

        private

        def retrieve_proposals_followers(from_start: false)
          @proposals_followers ||= Decidim::Follow.where(followable: retrieve_proposals).joins(:user)
                                                  .where("decidim_follows.created_at <= ?", end_time)

          return @proposals_followers.where("decidim_follows.created_at >= ?", start_time) if from_start

          @proposals_followers
        end

        def retrieve_drafts_followers(from_start: false)
          @drafts_followers ||= Decidim::Follow.where(followable: retrieve_collaborative_drafts).joins(:user)
                                               .where("decidim_follows.created_at <= ?", end_time)
          return @drafts_followers.where("decidim_follows.created_at >= ?", start_time) if from_start

          @drafts_followers
        end

        def retrieve_proposals
          Decidim::Proposals::Proposal.where(component: @resource).except_withdrawn
        end

        def retrieve_collaborative_drafts
          Decidim::Proposals::CollaborativeDraft.where(component: @resource).except_withdrawn
        end
      end
    end
  end
end
