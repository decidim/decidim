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

      def link_to_resource
        link_to resource_locator(proposal).path, class: "button secondary light expanded button--sc mt-s" do
          t("published_proposal", scope: "decidim.proposals.collaborative_drafts.show")
        end
      end

      def link_header
        tag.strong(class: "text-large") do
          t("final_proposal", scope: "decidim.proposals.collaborative_drafts.show")
        end
      end

      def link_help_text
        tag.span(class: "text-medium") do
          t("final_proposal_help_text", scope: "decidim.proposals.collaborative_drafts.show")
        end
      end

      def link_to_versions
        @path ||= decidim_proposals.collaborative_draft_versions_path(
          collaborative_draft_id: model.id
        )
        link_to @path, class: "text-medium" do
          tag.u do
            t("version_history", scope: "decidim.proposals.collaborative_drafts.show")
          end
        end
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
