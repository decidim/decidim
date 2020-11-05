# frozen_string_literal: true

module Decidim
  module Budgets
    module Metrics
      # Searches for Participants in the following actions
      #  - Vote a participatory budgeting project (Budgets)
      class BudgetParticipantsMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          budgets = Decidim::Budgets::Budget.where(component: @resource)
          orders = Decidim::Budgets::Order.where(budget: budgets)
                                          .finished
                                          .where("decidim_budgets_orders.checked_out_at <= ?", end_time)

          {
            cumulative_users: orders.pluck(:decidim_user_id),
            quantity_users: orders.where("decidim_budgets_orders.checked_out_at >= ?", start_time).pluck(:decidim_user_id)
          }
        end
      end
    end
  end
end
