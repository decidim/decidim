# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeDropdownMetadataCell < Decidim::ParticipatorySpaceDropdownMetadataCell
      include Decidim::TwitterSearchHelper
      include InitiativesHelper
      include Decidim::ComponentPathHelper
      include ActiveLinkTo

      alias initiative model
      alias current_participatory_space model

      def decidim_initiatives
        Decidim::Initiatives::Engine.routes.url_helpers
      end

      private

      def hashtag
        @hashtag ||= decidim_html_escape(initiative.hashtag) if initiative.hashtag.present?
      end

      def nav_items
        return super if (nav_items = try(:initiative_nav_items, initiative)).blank?

        nav_items
      end
    end
  end
end
