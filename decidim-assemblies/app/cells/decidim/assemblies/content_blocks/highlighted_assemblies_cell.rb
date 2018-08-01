# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class HighlightedAssembliesCell < Decidim::ViewModel
        delegate :current_organization, to: :controller
        delegate :current_user, to: :controller

        def show
          render if highlighted_assemblies.any?
        end

        def highlighted_assemblies
          OrganizationPrioritizedAssemblies.new(current_organization, current_user)
        end

        def i18n_scope
          "decidim.assemblies.pages.home.highlighted_assemblies"
        end

        def decidim_assemblies
          Decidim::Assemblies::Engine.routes.url_helpers
        end
      end
    end
  end
end
