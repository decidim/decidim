# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      class HighlightedVotingsCell < Decidim::ViewModel
        delegate :current_user, to: :controller

        def show
          render if highlighted_votings.any?
        end

        def max_results
          model.settings.max_results
        end

        def highlighted_votings
          OrganizationPrioritizedVotings.new(current_organization, current_user)
                                        .query
                                        .limit(max_results)
        end

        def i18n_scope
          "decidim.votings.pages.home.highlighted_votings"
        end

        def decidim_votings
          Decidim::Votings::Engine.routes.url_helpers
        end
      end
    end
  end
end
