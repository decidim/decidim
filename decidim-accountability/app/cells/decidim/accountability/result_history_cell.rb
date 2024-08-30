# frozen_string_literal: true

module Decidim
  module Accountability
    # This cell renders a project
    class ResultHistoryCell < Decidim::ViewModel
      include Decidim::Accountability::ApplicationHelper

      def show
        render
      end

      private

      def history_items
        return @history_items if @history_items.present?

        @history_items = []
        add_linked_resources_items(@history_items, :proposals, "included_proposals", "result.proposals", "Decidim::Proposals::Proposal")
        add_linked_resources_items(@history_items, :projects, "included_projects", "result.project_ids", "Decidim::Budgets::Project")
        add_linked_resources_items(@history_items, :meetings, "meetings_through_proposals", "result.meetings_ids", "Decidim::Meetings::Meeting")
        add_result_creation_item(@history_items) if @history_items.any?

        @history_items.sort_by! { |item| item[:date] }
      end

      def add_linked_resources_items(items, resource_type, link_name, text_key, icon_key)
        resources = @model.linked_resources(resource_type, link_name)
        return if resources.blank?

        resources.each do |resource|
          items << {
            id: "#{link_name}_#{resource.id}",
            date: resource.updated_at,
            text: t(text_key, scope: "activemodel.attributes", count: 1),
            icon: resource_type_icon_key(icon_key),
            url: resource_locator(resource).path,
            resource:
          }
        end
      end

      def add_result_creation_item(items)
        items << {
          id: "result_creation",
          date: @model.created_at,
          text: t("decidim.accountability.creation.text"),
          icon: resource_type_icon_key("Decidim::Accountability::Result")
        }
      end
    end
  end
end
