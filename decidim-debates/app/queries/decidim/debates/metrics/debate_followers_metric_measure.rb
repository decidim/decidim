# frozen_string_literal: true

module Decidim
  module Debates
    module Metrics
      # Searches for unique Users following the next objects
      #  - Debates
      class DebateFollowersMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          debates = Decidim::Debates::Debate.where(component: @resource).joins(:component)

          debates_followers = Decidim::Follow.where(followable: debates).joins(:user)
                                             .where("decidim_follows.created_at <= ?", end_time)
          cumulative_users = debates_followers.pluck(:decidim_user_id)

          debates_followers = debates_followers.where("decidim_follows.created_at >= ?", start_time)
          quantity_users = debates_followers.pluck(:decidim_user_id)

          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end
      end
    end
  end
end
