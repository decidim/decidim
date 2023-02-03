# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceDropdownMetadataCell < Decidim::ParticipatorySpaceDropdownMetadataCell
      include Decidim::TwitterSearchHelper
      include ConferenceHelper
      include Decidim::ComponentPathHelper
      include ActiveLinkTo

      alias conference model
      alias current_participatory_space model

      def decidim_conferences
        Decidim::Conferences::Engine.routes.url_helpers
      end

      private

      def hashtag
        @hashtag ||= decidim_html_escape(conference.hashtag) if conference.hashtag.present?
      end

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
