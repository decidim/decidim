# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies filter by type.
    #
    # `filter` returns a Filter object from Decidim::FilterResource
    module FilterAssembliesHelper
      def available_filters
        @available_filters ||= [t("all", scope: "decidim.assemblies.filter")] + organization_assembly_types
      end

      def filter_link(type_id)
        Decidim::Assemblies::Engine
          .routes
          .url_helpers
          .assemblies_path(
            filter: {
              scope_id: filter.scope_id,
              area_id: filter.area_id,
              type_id: type_id
            }
          )
      end

      def help_text
        t("help", scope: "decidim.assemblies.filter")
      end

      def current_filter_name
        type = AssembliesType.find_by(id: filter.type_id)
        return translated_attribute type.title if type

        t("all", scope: "decidim.assemblies.filter")
      end

      def organization_assembly_types
        AssembliesType.where(organization: current_organization)&.map { |type| [translated_attribute(type.title), type.id] }
      end
    end
  end
end
