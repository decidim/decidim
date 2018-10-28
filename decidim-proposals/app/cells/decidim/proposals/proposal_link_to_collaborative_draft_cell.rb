# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the link to the source collaborative draft of a proposal.
    class ProposalLinkToCollaborativeDraftCell < Decidim::ViewModel
      def show
        render if collaborative_draft
      end

      private

      def collaborative_draft
        @collaborative_draft ||= model.linked_resources(:collaborative_draft, "created_from_collaborative_draft").first
      end

      def link_to_resource
        link_to resource_locator(collaborative_draft).path, class: "link" do
          t("link_to_collaborative_draft_text", scope: "decidim.proposals.proposals.show")
        end
      end

      def link_help_text
        t("link_to_collaborative_draft_help_text", scope: "decidim.proposals.proposals.show")
      end
    end
  end
end
