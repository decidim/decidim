# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell is used to render the budget history panel of a resource
    # inside a tab of a show view
    #
    # The `model` must be a resource to get the budget history from.and is expected to
    # respond to budget history method
    #
    # Example:
    #
    #   cell(
    #     "decidim/budget_history",
    #     budget
    #   )
    class BudgetHistoryCell < Decidim::ResourceHistoryCell
      include Decidim::Budgets::ApplicationHelper

      private

      def add_history_items
        add_linked_resources_items(@history_items, :proposals, "included_proposals", "decidim/proposals/proposal/budget_text", "Decidim::Proposals::Proposal")
        add_linked_resources_items(@history_items, :results, "included_projects", "decidim/accountability/result/budget_text", "Decidim::Accountability::Result")
        add_budget_creation_item(@history_items) if @history_items.any?
      end

      def add_budget_creation_item(items)
        items << {
          id: "budget_creation",
          date: @model.created_at,
          text: t("decidim.budgets.creation.text"),
          icon: resource_type_icon_key("Decidim::Budgets::Project")
        }
      end

      def history_cell_id
        "budget"
      end
    end
  end
end
