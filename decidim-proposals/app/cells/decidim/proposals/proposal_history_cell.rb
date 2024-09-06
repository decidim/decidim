# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell is used to render the proposal history panel of a resource
    # inside a tab of a show view
    #
    # The `model` must be a resource to get the proposal history from.and is expected to
    # respond to proposal history method
    #
    # Example:
    #
    #   cell(
    #     "decidim/proposal_history",
    #     proposal
    #   )
    class ProposalHistoryCell < Decidim::ViewModel
      include Decidim::Proposals::ApplicationHelper

      def show
        render
      end

      private

      def history_items
        return @history_items if @history_items.present?

        @history_items = []
        # linked resources generate from this proposal
        resources = @model.linked_resources_from(:proposals, "copied_from_component")
        add_linked_resources_items(@history_items, resources, "copied_from_component", "decidim/proposals/proposal/import_from_proposal_text", "Decidim::Proposals::Proposal")
        resources = @model.linked_resources_from(:proposals, "splitted_from_component")
        add_linked_resources_items(@history_items, resources, "splitted_from_component", "decidim/proposals/proposal/split_from_proposal_text", "Decidim::Proposals::Proposal")
        resources = @model.linked_resources_from(:proposals, "merged_from_component")
        add_linked_resources_items(@history_items, resources, "merged_from_component", "decidim/proposals/proposal/merge_from_proposal_text", "Decidim::Proposals::Proposal")

        resources = @model.linked_resources(:projects, "included_proposals")
        add_linked_resources_items(@history_items, resources, "included_proposals", "decidim/budgets/project/text", "Decidim::Budgets::Project")
        resources = @model.linked_resources(:results, "included_proposals")
        add_linked_resources_items(@history_items, resources, "included_proposals", "decidim/accountability/result/text", "Decidim::Accountability::Result")
        resources = @model.linked_resources(:meetings, "proposals_from_meeting")
        add_linked_resources_items(@history_items, resources, "proposals_from_meeting", "decidim/meetings/meeting/text", "Decidim::Meetings::Meeting")

        # linked resource generate to this proposal
        resources = @model.linked_resources_to(:proposals, "copied_from_component")
        add_linked_resources_items(@history_items, resources, "copied_to_component", "decidim/proposals/proposal/import_to_proposal_text", "Decidim::Proposals::Proposal")
        resources = @model.linked_resources_to(:proposals, "splitted_from_component")
        add_linked_resources_items(@history_items, resources, "splitted_to_component", "decidim/proposals/proposal/split_to_proposal_text", "Decidim::Proposals::Proposal")
        resources = @model.linked_resources_to(:proposals, "merged_from_component")
        add_linked_resources_items(@history_items, resources, "merged_to_component", "decidim/proposals/proposal/merge_to_proposal_text", "Decidim::Proposals::Proposal")

        add_proposal_creation_item(@history_items) if @history_items.any?

        @history_items.sort_by! { |item| item[:date] }
      end

      def add_linked_resources_items(items, resources, link_name, text_key, icon_key)
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

      def add_proposal_creation_item(items)
        creation_text = if history_items_contains?(:merged_from_component)
                          t("decidim.proposals.creation.merged_text")
                        elsif history_items_contains?(:splitted_to_component)
                          t("decidim.proposals.creation.imported_and_splitted_text")
                        else
                          t("decidim.proposals.creation.text")
                        end
        items << {
          id: "proposal_creation",
          date: @model.created_at,
          text: creation_text,
          icon: resource_type_icon_key("Decidim::Proposals::Proposal")
        }
      end

      def history_items_contains?(link_name)
        return false if @history_items.blank?

        @history_items.any? { |item| item[:id].include?(link_name.to_s) }
      end
    end
  end
end
