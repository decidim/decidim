# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the highlighted proposals for a given participatory
    # space. It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedProposalsCell < Decidim::ViewModel
      include ProposalCellsHelper

      private

      def published_components
        Decidim::Component
          .where(
            participatory_space: model,
            manifest_name: :proposals
          )
          .published
      end
    end
  end
end
