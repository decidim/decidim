# frozen_string_literal: true

module Decidim
  module Accountability
    # This cell renders a project
    class ResultHistoryCell < Decidim::ResourceHistoryCell
      include Decidim::Accountability::ApplicationHelper

      private

      def add_history_items
        add_linked_resources_items(@history_items, :proposals, "included_proposals", "result.proposals", "Decidim::Proposals::Proposal")
        add_linked_resources_items(@history_items, :projects, "included_projects", "result.project_ids", "Decidim::Budgets::Project")
        add_linked_resources_items(@history_items, :meetings, "meetings_through_proposals", "result.meetings_ids", "Decidim::Meetings::Meeting")
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
