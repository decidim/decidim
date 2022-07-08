# frozen_string_literal: true

module Decidim
  module Conferences
    module ContentBlocks
      class HighlightedConferencesCell < Decidim::ViewModel
        delegate :current_user, to: :controller

        cache :show, expires_in: 10.minutes, if: :perform_caching? do
          cache_hash
        end

        def show
          render if highlighted_conferences.any?
        end

        def highlighted_conferences
          OrganizationPrioritizedConferences.new(current_organization, current_user)
        end

        def i18n_scope
          "decidim.conferences.pages.home.highlighted_conferences"
        end

        def decidim_conferences
          Decidim::Conferences::Engine.routes.url_helpers
        end

        private

        def cache_hash
          hash = []
          hash.push(I18n.locale)
          hash.push(highlighted_conferences.map(&:cache_key_with_version))
          hash.join(Decidim.cache_key_separator)
        end
      end
    end
  end
end
