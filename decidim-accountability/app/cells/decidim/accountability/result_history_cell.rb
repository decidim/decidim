# frozen_string_literal: true

module Decidim
  module Accountability
    # This cell is used to render a result history panel of a resource
    # inside a tab of a show view
    #
    # The `model` must be an accountability result resource to get the history from.
    #
    # Example:
    #
    #   cell(
    #     "decidim/result_history",
    #     result
    #   )
    class ResultHistoryCell < Decidim::ResourceHistoryCell
      include Decidim::Accountability::ApplicationHelper

      def linked_resources_items
        [
          {
            resources: @model.linked_resources(:proposals, "included_proposals"),

            link_name: "included_proposals",
            text_key: "decidim.accountability.result.proposal_ids",
            icon_key: "Decidim::Proposals::Proposal"
          },
          {
            resources: @model.linked_resources(:projects, "included_projects"),
            link_name: "included_projects",
            text_key: "decidim.accountability.result.project_ids",
            icon_key: "Decidim::Budgets::Project"
          },
          {
            resources: @model.linked_resources(:meetings, "meetings_through_proposals"),
            link_name: "meetings_through_proposals",
            text_key: "decidim.accountability.result.meetings_ids",
            icon_key: "Decidim::Meetings::Meeting"
          }
        ]
      end

      def creation_item
        {
          id: "result_creation",
          date: @model.created_at,
          text: t("decidim.accountability.creation.text"),
          icon: resource_type_icon_key("Decidim::Accountability::Result")
        }
      end

      def history_cell_id
        "result"
      end
    end
  end
end
