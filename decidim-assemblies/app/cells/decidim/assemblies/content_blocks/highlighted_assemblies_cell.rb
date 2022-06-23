# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class HighlightedAssembliesCell < Decidim::ViewModel
        delegate :current_user, to: :controller

        def show
          render if highlighted_assemblies.any?
        end

        def max_results
          model.settings.max_results
        end

        def highlighted_assemblies
          @highlighted_assemblies ||= OrganizationPrioritizedAssemblies
                                      .new(current_organization, current_user)
                                      .query
                                      .with_attached_hero_image
                                      .includes([:organization])
                                      .limit(max_results)
        end

        def i18n_scope
          "decidim.assemblies.pages.home.highlighted_assemblies"
        end

        def decidim_assemblies
          Decidim::Assemblies::Engine.routes.url_helpers
        end

        private

        def cache_hash
          hash = []
          hash.push(I18n.locale)
          hash.push(highlighted_assemblies.map(&:cache_key_with_version))
          hash.join(Decidim.cache_key_separator)
        end

        def cache_expiry_time
          10.minutes
        end
      end
    end
  end
end
