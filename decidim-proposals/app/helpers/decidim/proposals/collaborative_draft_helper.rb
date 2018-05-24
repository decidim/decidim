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
    end
  end
end
