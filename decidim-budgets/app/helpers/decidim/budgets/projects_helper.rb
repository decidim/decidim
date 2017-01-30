# frozen_string_literal: true
module Decidim
  module Budgets
    # TODO
    module ProjectsHelper
      def budget_to_currency(budget)
        number_to_currency budget, unit: "€", delimiter: ".", precision: 0, format: "%n %u"
      end
    end
  end
end
