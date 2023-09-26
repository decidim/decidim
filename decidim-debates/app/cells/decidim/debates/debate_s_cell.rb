# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Debates
    # This cell renders the Search (:s) debate card
    # for a given instance of a Debate
    class DebateSCell < Decidim::CardSCell
      private

      def title
        present(model).title(html_escape: true)
      end

      def metadata_cell
        "decidim/debates/debate_card_metadata"
      end
    end
  end
end
