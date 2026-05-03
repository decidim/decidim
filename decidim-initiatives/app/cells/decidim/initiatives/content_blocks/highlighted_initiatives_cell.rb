# frozen_string_literal: true

module Decidim
  module Initiatives
    module ContentBlocks
      class HighlightedInitiativesCell < Decidim::ContentBlocks::HighlightedParticipatorySpacesCell
        BLOCK_ID = "highlighted-initiatives"

        delegate :current_organization, to: :controller

        def highlighted_spaces
          @highlighted_spaces ||= OrganizationPrioritizedInitiatives
                                  .new(current_organization, order)
                                  .query
        end

        def i18n_scope
          "decidim.initiatives.pages.home.highlighted_initiatives"
        end

        def all_path
          Decidim::Initiatives::Engine.routes.url_helpers.initiatives_path(locale: current_locale)
        end

        private

        def max_results
          model.settings.max_results
        end

        def order
          model.settings.order
        end

        def block_id = BLOCK_ID
      end
    end
  end
end
