# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      class HighlightedVotingsCell < Decidim::ContentBlocks::HighlightedParticipatorySpacesCell
        BLOCK_ID = "highlighted-votings"

        delegate :current_user, to: :controller

        def highlighted_spaces
          @highlighted_spaces ||= OrganizationPrioritizedVotings.new(current_organization, current_user).query
        end

        def i18n_scope
          "decidim.votings.pages.home.highlighted_votings"
        end

        def all_path
          Decidim::Votings::Engine.routes.url_helpers.votings_path
        end

        def max_results
          model.settings.max_results
        end

        private

        def block_id = BLOCK_ID
      end
    end
  end
end
