# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its L-size card.
    class CollaborativeDraftLCell < Decidim::CardLCell
      private

      def metadata_cell
        "decidim/proposals/collaborative_draft_metadata"
      end
    end
  end
end
