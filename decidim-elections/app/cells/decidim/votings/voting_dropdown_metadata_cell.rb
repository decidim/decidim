# frozen_string_literal: true

module Decidim
  module Votings
    class VotingDropdownMetadataCell < Decidim::ParticipatorySpaceDropdownMetadataCell
      include VotingsHelper
      include Decidim::ComponentPathHelper
      include ActiveLinkTo

      def decidim_votings
        Decidim::Votings::Engine.routes.url_helpers
      end

      private

      def nav_items_method = :voting_nav_items
    end
  end
end
