# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the Search (:s) process card
    # for an given instance of a Assembly
    class AssemblySCell < Decidim::CardSCell
      private

      def metadata_cell
        "decidim/assemblies/assembly_metadata_g"
      end
    end
  end
end
