# frozen_string_literal: true

module Decidim
  module Accountability
    # This cell renders a project
    class ResultHistoryCell < Decidim::ResourceHistoryCell
      private

      def add_history_items
        resources = @model.linked_resources(:proposals, "included_proposals")
        add_linked_resources_items(@history_items, resources, "included_proposals", "decidim/accountability/result/proposal_ids", "Decidim::Proposals::Proposal")
        resources = @model.linked_resources(:projects, "included_projects")
        add_linked_resources_items(@history_items, resources, "included_projects", "decidim/accountability/result/project_ids", "Decidim::Budgets::Project")
        resources = @model.linked_resources(:meetings, "meetings_through_proposals")
        add_linked_resources_items(@history_items, resources, "meetings_through_proposals", "decidim/accountability/result/meetings_ids", "Decidim::Meetings::Meeting")
        add_result_creation_item(@history_items) if @history_items.any?
      end

      def add_result_creation_item(items)
        items << {
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
