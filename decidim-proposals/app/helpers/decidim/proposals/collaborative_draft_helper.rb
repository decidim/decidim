# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the collaborative_draft resource.
    #
    module CollaborativeDraftHelper
      def filter_collaborative_drafts_state_values
        scope = "decidim.proposals.collaborative_drafts.filters"
        Decidim::CheckBoxesTreeHelper::TreeNode.new(
          Decidim::CheckBoxesTreeHelper::TreePoint.new("", filter_text_for(t("all", scope:))),
          [
            Decidim::CheckBoxesTreeHelper::TreePoint.new("open", filter_text_for(t("open", scope:))),
            Decidim::CheckBoxesTreeHelper::TreePoint.new("withdrawn", filter_text_for(t("withdrawn", scope:))),
            Decidim::CheckBoxesTreeHelper::TreePoint.new("published", filter_text_for(t("published", scope:)))
          ]
        )
      end

      def humanize_collaborative_draft_state(state)
        I18n.t(state, scope: "decidim.proposals.collaborative_drafts.states", default: :open)
      end

      def collaborative_drafts_state_class(type)
        case type
        when "withdrawn"
          "alert"
        when "open", "published"
          "success"
        end
      end

      def accept_request_button_label
        t("accept_request", scope: "decidim.proposals.collaborative_drafts.requests.collaboration_requests")
      end

      def reject_request_button_label
        t("reject_request", scope: "decidim.proposals.collaborative_drafts.requests.collaboration_requests")
      end
    end
  end
end
