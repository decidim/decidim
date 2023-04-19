# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceDropdownMetadataCell < Decidim::ParticipatorySpaceDropdownMetadataCell
      include ConferenceHelper
      include Decidim::ComponentPathHelper
      include ActiveLinkTo

      def decidim_conferences
        Decidim::Conferences::Engine.routes.url_helpers
      end

      private

      def nav_items
        return super unless try(:conference_nav_items)

        # Correct the conference_nav_items to avoid this hack using the correct
        # keys
        conference_nav_items.map do |item|
          item[:url] = item.delete :path
          item
        end
      end
    end
  end
end
