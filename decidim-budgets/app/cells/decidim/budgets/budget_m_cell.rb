# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the Medium (:m) budget card
    # for an given instance of a Decidim::Budgets::Budget
    class BudgetMCell < Decidim::CardMCell
      include ActiveSupport::NumberHelper
      include Decidim::Budgets::ProjectsHelper

      def statuses
        []
      end
    end
  end
end
