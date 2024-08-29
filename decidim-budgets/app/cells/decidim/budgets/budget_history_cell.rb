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
    class BudgetHistoryCell < Decidim::ViewModel
      include Decidim::Budgets::ApplicationHelper

      def show
        render
      end

      private

      def history_items
        return @history_items if @history_items.present?

        @history_items = []
        add_linked_resources_items(@history_items, :proposals, "included_proposals", "decidim/proposals/proposal/budget_text", "Decidim::Proposals::Proposal")
        add_budget_creation_item(@history_items) if @history_items.any?

        @history_items.sort_by! { |item| item[:date] }
      end

      def add_linked_resources_items(items, resource_type, link_name, text_key, icon_key)
        resources = @model.linked_resources(resource_type, link_name)
        return if resources.blank?

        resources.each do |resource|
          items << {
            id: "#{link_name}_#{resource.id}",
            date: resource.updated_at,
            text: t(text_key, scope: "activerecord.models", count: 1),
            icon: resource_type_icon_key(icon_key),
            url: resource_locator(resource).path,
            resource:
          }
        end
      end

      def add_budget_creation_item(items)
        items << {
          id: "budget_creation",
          date: @model.created_at,
          text: t("decidim.budgets.creation.text"),
          icon: resource_type_icon_key("Decidim::Budgets::Project")
        }
      end
    end
  end
end
