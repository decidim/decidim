# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the collaborative_draft resource.
    #
    module CollaborativeDraftHelper
      def render_access_request_btn?
        return false if render_access_requested_btn?
        allowed_to?(:request_access, :collaborative_draft, collaborative_draft: @collaborative_draft)
      end

      def render_access_requested_btn?
        @collaborative_draft.access_requestors.exists? current_user.id
      end

      def render_edit_btn?
        allowed_to?(:edit, :collaborative_draft, collaborative_draft: @collaborative_draft)
      end

      def collaborative_drafts_states_collection
        scope = "decidim.proposals.collaborative_drafts.filters"
        @collaborative_drafts_states_collection ||= begin
          collection = []
          collection << ["all", t("all", scope: scope)]
          collection << ["open", t("open", scope: scope)]
          collection << ["closed", t("closed", scope: scope)]
          collection << ["published", t("published", scope: scope)]
          collection
        end
      end

      def accept_request_btn_lbl
        t("accept_request", scope: "decidim.proposals.collaborative_drafts.requests.collaboration_requests")
      end

      def reject_request_btn_lbl
        t("reject_request", scope: "decidim.proposals.collaborative_drafts.requests.collaboration_requests")
      end
    end
  end
end
