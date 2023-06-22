# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Debates
    # This cell renders the Small (:s) debate card
    # for an given instance of a Debate
    class DebateSCell < Decidim::CardSCell
      private

      def metadata_cell
        "decidim/debates/debate_card_metadata"
      end
    end
  end
end
