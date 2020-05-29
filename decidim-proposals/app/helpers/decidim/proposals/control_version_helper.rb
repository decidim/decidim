# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    module ControlVersionHelper
      def back_to_resource_path_text_scope
        case item_name
        when :proposal
          "decidim.proposals.versions.proposals"
        when :collaborative_draft
          "decidim.proposals.versions.collaborative_drafts"
        end
      end
    end
  end
end
