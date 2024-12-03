# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell is used to render the proposal history panel of a resource
    # inside a tab of a show view
    #
    # The `model` must be a proposal resource to get the history from.
    #
    # Example:
    #
    #   cell(
    #     "decidim/proposal_history",
    #     proposal
    #   )
    class ProposalHistoryCell < Decidim::ResourceHistoryCell
      include Decidim::Proposals::ApplicationHelper

      private

      def linked_resources_items
        # linked resources generate from this proposal
        [
          {
            resources: @model.linked_resources_from(:proposals, "copied_from_component"),
            link_name: "copied_from_component",
            text_key: "decidim.proposals.proposal.import_from_proposal_text",
            icon_key: "Decidim::Proposals::Proposal"
          },
          {
            resources: @model.linked_resources_from(:proposals, "merged_from_component"),
            link_name: "merged_from_component",
            text_key: "decidim.proposals.proposal.merge_from_proposal_text",
            icon_key: "Decidim::Proposals::Proposal"
          },
          {

            resources: @model.linked_resources(:projects, "included_proposals"),
            link_name: "included_proposals",
            text_key: "decidim.budgets.project.text",
            icon_key: "Decidim::Budgets::Project"
          },
          {
            resources: @model.linked_resources(:results, "included_proposals"),
            link_name: "included_proposals",
            text_key: "decidim.accountability.result.text",
            icon_key: "Decidim::Accountability::Result"
          },
          {
            resources: @model.linked_resources(:meetings, "proposals_from_meeting"),
            link_name: "proposals_from_meeting",
            text_key: "decidim.meetings.meeting.text",
            icon_key: "Decidim::Meetings::Meeting"
          },
          {

            # linked resource generate to this proposal
            resources: @model.linked_resources_to(:proposals, "copied_from_component"),
            link_name: "copied_to_component",
            text_key: "decidim.proposals.proposal.import_to_proposal_text",
            icon_key: "Decidim::Proposals::Proposal"
          },
          {
            resources: @model.linked_resources_to(:proposals, "merged_from_component"),
            link_name: "merged_to_component",
            text_key: "decidim.proposals.proposal.merge_to_proposal_text",
            icon_key: "Decidim::Proposals::Proposal"
          }
        ]
      end

      def creation_item
        creation_text = if history_items_contains?(:merged_to_component)
                          t("decidim.proposals.creation.merged_text")
                        elsif history_items_contains?(:copied_to_component)
                          t("decidim.proposals.creation.imported_text")
                        else
                          t("decidim.proposals.creation.text")
                        end
        {
          id: "proposal_creation",
          date: @model.created_at,
          text: creation_text,
          icon: resource_type_icon_key("Decidim::Proposals::Proposal")
        }
      end

      def history_cell_id
        "proposal"
      end
    end
  end
end
