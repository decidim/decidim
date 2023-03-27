# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class MainDataCell < Decidim::ContentBlocks::ParticipatorySpaceMainDataCell
        include AssembliesHelper
        include Decidim::ComponentPathHelper
        include ActiveLinkTo

        delegate :short_description, to: :resource

        private

        def decidim_assemblies
          Decidim::Assemblies::Engine.routes.url_helpers
        end

        def title_text
          t("title", scope: "decidim.assemblies.assemblies.show")
        end

        def description_text
          decidim_sanitize_editor_admin translated_attribute(short_description)
        end

        def details_path
          decidim_assemblies.description_assembly_path(resource)
        end

        def nav_items
          assembly_nav_items(resource)
        end
      end
    end
  end
end
