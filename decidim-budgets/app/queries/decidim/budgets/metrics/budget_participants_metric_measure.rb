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
          budgets = Decidim::Budgets::Order.where(component: @resource).joins(:component)
                                           .finished
                                           .where("decidim_budgets_orders.checked_out_at <= ?", end_time)

          {
            cumulative_users: budgets.pluck(:decidim_user_id),
            quantity_users: budgets.where("decidim_budgets_orders.checked_out_at >= ?", start_time).pluck(:decidim_user_id)
          }
        end
      end
    end
  end
end
