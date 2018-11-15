# frozen_string_literal: true

module Decidim
  module Budgets
    module Metrics
      class BudgetFollowersMetricMeasure < Decidim::MetricMeasure
        # Searches for unique Users following the next objects
        #  - Budgets

        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          budgets = Decidim::Budgets::Project.where(component: @resource).joins(:component)

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
