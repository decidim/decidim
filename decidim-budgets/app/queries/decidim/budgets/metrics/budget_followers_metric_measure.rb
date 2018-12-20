# frozen_string_literal: true

module Decidim
  module Budgets
    module Metrics
      # Searches for unique Users following the next objects
      #  - Budgets
      class BudgetFollowersMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          budgets = Decidim::Budgets::Project.where(component: @resource)

          budgets_followers = Decidim::Follow.where(followable: budgets).joins(:user)
                                             .where("decidim_follows.created_at <= ?", end_time)
          cumulative_users = budgets_followers.pluck(:decidim_user_id)

          budgets_followers = budgets_followers.where("decidim_follows.created_at >= ?", start_time)
          quantity_users = budgets_followers.pluck(:decidim_user_id)

          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end
      end
    end
  end
end
