# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies layout.
    module AssembliesHelper
      include Decidim::ResourceHelper
      include Decidim::AttachmentsHelper
      include Decidim::IconHelper
      include Decidim::SanitizeHelper
      include Decidim::ResourceReferenceHelper
      include Decidim::FiltersHelper
      include FilterAssembliesHelper

      # Items to display in the navigation of an assembly
      def assembly_nav_items(participatory_space)
        components = participatory_space.components.published.or(Decidim::Component.where(id: try(:current_component)))

        [
          *(if participatory_space.members_public_page?
              [{
                name: t("assembly_member_menu_item", scope: "layouts.decidim.assembly_navigation"),
                url: decidim_assemblies.assembly_participatory_space_private_users_path(participatory_space, locale: current_locale),
                active: is_active_link?(decidim_assemblies.assembly_participatory_space_private_users_path(participatory_space, locale: current_locale), :inclusive)
              }]
            end
           )
        ] + components.map do |component|
          {
            name: decidim_escape_translated(component.name),
            url: main_component_path(component),
            active: is_active_link?(main_component_path(component), :inclusive)
          }
        end.compact
      end
    end
  end
end
