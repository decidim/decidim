# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell is used to render the project history panel of a resource
    # inside a tab of a show view
    #
    # The `model` must be a project's budget resource to get the history from.
    #
    # Example:
    #
    #   cell(
    #     "decidim/project_history",
    #     budget
    #   )
    class ProjectHistoryCell < Decidim::ResourceHistoryCell
      def linked_resources_items
        [
          {
            resources: @model.linked_resources(:proposals, "included_proposals"),
            link_name: "included_proposals",
            text_key: "decidim.proposals.proposal.budget_text",
            icon_key: "Decidim::Proposals::Proposal"
          },
          {
            resources: @model.linked_resources(:results, "included_projects"),
            link_name: "included_projects",
            text_key: "decidim.accountability.result.budget_text",
            icon_key: "Decidim::Accountability::Result"
          }
        ]
      end

      def creation_item
        {
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
