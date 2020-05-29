# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    module ControlVersionHelper
      def item_name
        versioned_resource.model_name.singular_route_key.to_sym
      end

      def back_to_resource_path_text_scope
        case item_name
        when :proposal
          "decidim.proposals.versions.proposals"
        when :collaborative_draft
          "decidim.proposals.versions.collaborative_drafts"
        end
      end

      def back_to_resource_path_text
        case item_name
        when :proposal
          t("back_to_proposal", scope: "decidim.proposals.versions.stats")
        when :collaborative_draft
          t("back_to_collaborative_draft", scope: "decidim.proposals.versions.stats")
        end
      end

      def back_to_resource_path
        case item_name
        when :proposal
          proposal_path(versioned_resource)
        when :collaborative_draft
          collaborative_draft_path(versioned_resource)
        end
      end

      def resource_version_path(index)
        case item_name
        when :proposal
          proposal_version_path(versioned_resource, index + 1)
        when :collaborative_draft
          collaborative_draft_version_path(versioned_resource, index + 1)
        end
      end

      def resource_all_versions_path
        case item_name
        when :proposal
          proposal_versions_path(versioned_resource)
        when :collaborative_draft
          collaborative_draft_versions_path(versioned_resource)
        end
      end
    end
  end
end
