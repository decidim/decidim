# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the Search (:s) conference card
    # for a given instance of a Conference
    class ConferenceSCell < Decidim::CardSCell
      def metadata_cell
        "decidim/conferences/conference_metadata"
      end
    end
  end
end
