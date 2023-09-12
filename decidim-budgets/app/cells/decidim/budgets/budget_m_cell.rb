# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the Medium (:m) budget card
    # for a given instance of a Budget
    class BudgetMCell < Decidim::CardMCell
      include ActiveSupport::NumberHelper
      include Decidim::Budgets::ProjectsHelper

      def statuses
        []
      end
    end
  end
end
