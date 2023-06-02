# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeDropdownMetadataCell < Decidim::ParticipatorySpaceDropdownMetadataCell
      include InitiativesHelper
      include Decidim::ComponentPathHelper
      include ActiveLinkTo

      def decidim_initiatives
        Decidim::Initiatives::Engine.routes.url_helpers
      end

      private

      def nav_items_method = :initiative_nav_items
    end
  end
end
