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
    #     meeting
    #   )
    class ProposalHistoryCell < Decidim::ViewModel
      def show
        render
      end

      private

      def proposal_history_items
        @proposal_history_items ||= [].tap do |items|
          add_proposal_creation_item(items)
          add_linked_resources_item(items, :projects, "included_proposals", "decidim/budgets/project/text", "Decidim::Budgets::Project")
          add_linked_resources_item(items, :results, "included_proposals", "decidim/accountability/result/text", "Decidim::Accountability::Result")
          add_linked_resources_item(items, :meetings, "proposals_from_meeting", "decidim/meetings/meeting/text", "Decidim::Meetings::Meeting")
          add_linked_resources_item(items, :proposals, "copied_from_component", "decidim/proposals/proposal/text", "Decidim::Proposals::Proposal")
          add_proposal_state_item(items) if proposal_state(@model).present?
          add_proposal_withdraw_item(items) if proposal_withdrawn_state(@model).present?
        end

        @proposal_history_items.sort_by! { |item| item[:date] }
      end

      def add_linked_resources_item(items, resource_type, link_name, text_key, icon_key)
        resources = @model.linked_resources(resource_type, link_name)
        return if resources.blank?

        items << {
          id: link_name,
          date: resources.first.updated_at,
          text: t(text_key, scope: "activerecord.models", count: resources.size),
          icon: resource_type_icon_key(icon_key),
          url: resource_locator(resources.first).path,
          resources:
        }
      end

      def add_proposal_creation_item(items)
        items << {
          id: "proposal_creation",
          date: @model.created_at,
          text: t("decidim.proposals.creation.text"),
          icon: resource_type_icon_key("Decidim::Proposals::Proposal")
        }
      end

      def add_proposal_state_item(items)
        state = proposal_state(@model)
        items << {
          id: "proposal_state",
          date: @model.updated_at,
          text: t("decidim.proposals.state.text"),
          icon: resource_type_icon_key("Decidim::Proposals::Proposal"),
          state:
        }
      end

      def add_proposal_withdraw_item(items)
        state = proposal_withdrawn_state(@model)
        items << {
          id: "proposal_withdraw",
          date: @model.updated_at,
          text: t("decidim.proposals.withdraw.text"),
          icon: resource_type_icon_key("Decidim::Proposals::Proposal"),
          state:
        }
      end

      def proposal_state(proposal)
        translated_attribute(proposal&.proposal_state&.title)
      end

      def proposal_withdrawn_state(proposal)
        return humanize_proposal_state(:withdrawn).html_safe if proposal.withdrawn?
      end
    end
  end
end
