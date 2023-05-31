# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the collaborative_draft resource.
    #
    module CollaborativeDraftHelper
      def filter_collaborative_drafts_state_values
        scope = "decidim.proposals.collaborative_drafts.filters"
        Decidim::CheckBoxesTreeHelper::TreeNode.new(
          Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("all", scope:)),
          [
            Decidim::CheckBoxesTreeHelper::TreePoint.new("open", t("open", scope:)),
            Decidim::CheckBoxesTreeHelper::TreePoint.new("withdrawn", t("withdrawn", scope:)),
            Decidim::CheckBoxesTreeHelper::TreePoint.new("published", t("published", scope:))
          ]
        )
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
