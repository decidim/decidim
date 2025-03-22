# frozen_string_literal: true

module Decidim
  module Conferences
    module ContentBlocks
      class HighlightedConferencesCell < Decidim::ContentBlocks::HighlightedParticipatorySpacesCell
        def highlighted_spaces
          @highlighted_spaces ||= OrganizationPrioritizedConferences
                                  .new(current_organization, current_user)
                                  .query
                                  .with_attached_hero_image
                                  .includes([:organization])
        end

        def i18n_scope
          "decidim.conferences.pages.home.highlighted_conferences"
        end

        def all_path
          Decidim::Conferences::Engine.routes.url_helpers.conferences_path(locale: current_locale)
        end

        def max_results
          model.settings.max_results
        end

        private

        def block_id
          "highlighted-conferences"
        end
      end
    end
  end
end
