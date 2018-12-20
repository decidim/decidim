# frozen_string_literal: true

module Decidim
  module Meetings
    module Metrics
      # Searches for unique Users following the next objects
      #  - Meetings
      class MeetingFollowersMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          meetings = Decidim::Meetings::Meeting.where(component: @resource).joins(:component)

          meetings_followers = Decidim::Follow.where(followable: meetings).joins(:user)
                                              .where("decidim_follows.created_at <= ?", end_time)
          cumulative_users = meetings_followers.pluck(:decidim_user_id)

          meetings_followers = meetings_followers.where("decidim_follows.created_at >= ?", start_time)
          quantity_users = meetings_followers.pluck(:decidim_user_id)

          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end
      end
    end
  end
end
