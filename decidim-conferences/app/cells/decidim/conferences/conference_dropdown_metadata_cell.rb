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

      def nav_items_method = :conference_nav_items
    end
  end
end
