# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ControlVersionHelper
      def versions_controller?
        return true if params[:controller] == "decidim/proposals/versions"

        false
      end

      def proposal?
        return true if item.class == Decidim::Proposals::Proposal

        false
      end

      def back_to_resource_path_text
        return unless versions_controller?

        if proposal?
          t("versions.stats.back_to_proposal", scope: "decidim.proposals")
        else
          t("versions.stats.back_to_collaborative_draft", scope: "decidim.proposals")
        end
      end

      def back_to_resource_path
        return unless versions_controller?

        if proposal?
          proposal_path(item)
        else
          collaborative_draft_path(item)
        end
      end

      def resource_version_path(index)
        return unless versions_controller?

        if proposal?
          proposal_version_path(item, index + 1)
        else
          collaborative_draft_version_path(item, index + 1)
        end
      end

      def resource_all_versions_path
        return unless versions_controller?

        if proposal?
          proposal_versions_path(item)
        else
          collaborative_draft_versions_path(item)
        end
      end
    end
  end
end
