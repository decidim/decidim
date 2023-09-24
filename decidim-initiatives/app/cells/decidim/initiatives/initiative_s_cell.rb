# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the Search (:s) initiative card
    # for a given instance of an Initiative
    class InitiativeSCell < Decidim::CardSCell
      private

      def metadata_cell
        "decidim/initiatives/initiative_metadata_g"
      end
    end
  end
end
