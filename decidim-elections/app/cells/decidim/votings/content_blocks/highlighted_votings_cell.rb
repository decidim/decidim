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

        private

        def cache_hash
          hash = []
          hash.push(I18n.locale)
          hash.push(highlighted_votings.map(&:cache_key_with_version))
          hash.join(Decidim.cache_key_separator)
        end
      end
    end
  end
end
