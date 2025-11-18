# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Elections
    # This cell renders the Search (:s) election card
    # for a given instance of an Election
    class ElectionSCell < Decidim::CardSCell
      private

      def title
        present(model).title(html_escape: true)
      end

      def metadata_cell
        "decidim/elections/election_card_metadata"
      end
    end
  end
end
