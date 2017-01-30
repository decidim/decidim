# frozen_string_literal: true
module Decidim
  module Budgets
    # TODO
    module ProjectsHelper
      def budget_to_currency(budget)
        number_to_currency budget, unit: "€", delimiter: ".", precision: 0, format: "%n %u"
      end

      def current_order_total_budget_percentage
        return 0 unless current_order
        ((current_order.total_budget.to_f / feature_settings.total_budget.to_f) * 100).floor
      end
    end
  end
end
