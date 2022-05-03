# frozen_string_literal: true

module Decidim
  module Conferences
    module ContentBlocks
      class HighlightedConferencesCell < Decidim::ViewModel
        delegate :current_user, to: :controller

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
          hash.join(Decidim.cache_key_separator)
        end

        def cache_expiry_time
          10.minutes
        end
      end
    end
  end
end
