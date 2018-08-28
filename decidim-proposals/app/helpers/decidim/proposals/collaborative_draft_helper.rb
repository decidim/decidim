# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the collaborative_draft resource.
    #
    module CollaborativeDraftHelper
      def collaborative_drafts_states_collection
        scope = "decidim.proposals.collaborative_drafts.filters"
        @collaborative_drafts_states_collection ||= begin
          collection = []
          collection << ["all", t("all", scope: scope)]
          collection << ["open", t("open", scope: scope)]
          collection << ["withdrawn", t("withdrawn", scope: scope)]
          collection << ["published", t("published", scope: scope)]
          collection
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
