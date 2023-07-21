# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the List (:l) conference card
    # for an given instance of a Conference
    class ConferenceLCell < Decidim::CardLCell
      def metadata_cell
        "decidim/conferences/conference_metadata"
      end
    end
  end
end
