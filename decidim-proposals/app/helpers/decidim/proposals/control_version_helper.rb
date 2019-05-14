# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    module ControlVersionHelper
      def item_name
        item.model_name.singular_route_key.to_sym
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
          proposal_path(item)
        when :collaborative_draft
          collaborative_draft_path(item)
        end
      end

      def resource_version_path(index)
        case item_name
        when :proposal
          proposal_version_path(item, index + 1)
        when :collaborative_draft
          collaborative_draft_version_path(item, index + 1)
        end
      end

      def resource_all_versions_path
        case item_name
        when :proposal
          proposal_versions_path(item)
        when :collaborative_draft
          collaborative_draft_versions_path(item)
        end
      end

      # Outputs the diff as HTML with inline highlighting of the character
      # changes between lines.
      #
      # data - A Hash with `old_data`, `:new_data` and `:type` keys.
      #
      # Returns an HTML-safe string.
      def output_diff(data)
        Diffy::Diff.new(
          data[:old_value],
          data[:new_value],
        ).to_s(:html).html_safe
      end
    end
  end
end
