# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Metrics
      # Searches for unique Users following the next objects
      #  - ParticipatoryProcesses
      class ParticipatoryProcessFollowersMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Participable)
        end

        def calculate
          participatory_process = @resource

          process_followers = Decidim::Follow.where(followable: participatory_process).joins(:user)
                                             .where("decidim_follows.created_at <= ?", end_time)
          cumulative_users = process_followers.pluck(:decidim_user_id)

          process_followers = process_followers.where("decidim_follows.created_at >= ?", start_time)
          quantity_users = process_followers.pluck(:decidim_user_id)

          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end
      end
    end
  end
end
