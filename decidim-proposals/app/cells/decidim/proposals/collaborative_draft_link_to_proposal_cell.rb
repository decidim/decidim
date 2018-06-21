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
        link_resource_name = Decidim::Proposals::CollaborativeDraft.resource_manifest.link_resource_name[:proposals]
        model.linked_resources(:proposal, link_resource_name).first
      end

      def link_to_resource
        link_to resource_locator(proposal).path, class: "button secondary light expanded button--sc mt-s" do
          t("published_proposal", scope: "decidim.proposals.collaborative_drafts.show")
        end
      end

      def link_header
        content_tag :strong, class: "text-large text-uppercase" do
          t("final_proposal", scope: "decidim.proposals.collaborative_drafts.show")
        end
      end

      def link_help_text
        content_tag :span, class: "text-medium" do
          t("final_proposal_help_text", scope: "decidim.proposals.collaborative_drafts.show")
        end
      end

      def link_to_versions
        path = resource_locator(model).path + "/versions"
        link_to path, class: "text-medium" do
          content_tag :u do
            t("version_history", scope: "decidim.proposals.collaborative_drafts.show")
          end
        end
      end

      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end
    end
  end
end
