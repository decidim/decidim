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
      private

      def add_history_items
        resources = @model.linked_resources(:proposals, "included_proposals")
        add_linked_resources_items(@history_items, resources, {
                                     link_name: "included_proposals",
                                     text_key: "decidim/proposals/proposal/budget_text",
                                     icon_key: "Decidim::Proposals::Proposal"
                                   })
        resources = @model.linked_resources(:results, "included_projects")
        add_linked_resources_items(@history_items, resources, {
                                     link_name: "included_projects",
                                     text_key: "decidim/accountability/result/budget_text",
                                     icon_key: "Decidim::Accountability::Result"
                                   })
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
