# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the link to the published proposal of a collaborative draft.
    class CollaborativeDraftLinkToProposalCell < Decidim::ViewModel
      def show
        render if proposal
      end

      private

      def proposal
        @proposal ||= model.linked_resources(:proposal, "created_from_collaborative_draft").first
      end

      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end

      def decidim_proposals
        Decidim::EngineRouter.main_proxy(model.component)
      end
    end
  end
end
