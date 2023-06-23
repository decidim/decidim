# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders metadata for an instance of a budget
    class BudgetMetadataCell < Decidim::CardMetadataCell
      alias budget model

      def initialize(*)
        super

        @items.prepend(*budget_items)
      end

      private

      def budget_items
        [project_count]
      end

      def project_count
        {
          text: t(:projects_count, scope: "decidim.budgets.projects.count", count: budget.projects.size),
          icon: "git-pull-request-line"
        }
      end
    end
  end
end
