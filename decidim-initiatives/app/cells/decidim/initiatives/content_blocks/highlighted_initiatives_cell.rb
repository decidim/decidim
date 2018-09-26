# frozen_string_literal: true

module Decidim
  module Initiatives
    module ContentBlocks
      class HighlightedInitiativesCell < Decidim::ViewModel
        delegate :current_organization, to: :controller

        def show
          render if highlighted_initiatives.any?
        end

        def max_results
          model.settings.max_results
        end

        def highlighted_initiatives
          @highlighted_initiatives ||= OrganizationPrioritizedInitiatives
                                       .new(current_organization)
                                       .query
                                       .limit(max_results)
        end

        def i18n_scope
          "decidim.initiatives.pages.home.highlighted_initiatives"
        end

        def decidim_initiatives
          Decidim::Initiatives::Engine.routes.url_helpers
        end
      end
    end
  end
end
