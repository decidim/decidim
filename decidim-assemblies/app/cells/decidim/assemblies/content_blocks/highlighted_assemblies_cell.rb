# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class HighlightedAssembliesCell < Decidim::ContentBlocks::HighlightedParticipatorySpacesCell
        delegate :current_user, to: :controller

        def highlighted_spaces
          @highlighted_spaces ||= OrganizationPrioritizedAssemblies
                                  .new(current_organization, current_user)
                                  .query
                                  .with_attached_hero_image
                                  .includes([:organization])
        end

        def i18n_scope
          "decidim.assemblies.pages.home.highlighted_assemblies"
        end

        def all_path
          Decidim::Assemblies::Engine.routes.url_helpers.assemblies_path
        end

        def max_results
          model.settings.max_results
        end

        private

        def block_id
          "highlighted-assemblies"
        end
      end
    end
  end
end
