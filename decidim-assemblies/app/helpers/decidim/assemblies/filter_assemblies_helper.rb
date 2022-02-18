# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies filter by type.
    #
    # `filter` returns a Filter object from Decidim::FilterResource
    module FilterAssembliesHelper
      def available_filters
        return if organization_assembly_types.blank?

        [t("all", scope: "decidim.assemblies.filter")] + organization_assembly_types
      end

      def filter_link(type_id)
        Decidim::Assemblies::Engine
          .routes
          .url_helpers
          .assemblies_path(
            filter: {
              with_scope: filter.with_scope,
              with_area: filter.with_area,
              type_id_eq: type_id
            }
          )
      end

      def help_text
        t("help", scope: "decidim.assemblies.filter")
      end

      def current_filter_name
        type = AssembliesType.find_by(id: filter_params[:type_id_eq])
        return translated_attribute type.title if type

        t("all", scope: "decidim.assemblies.filter")
      end

      def organization_assembly_types
        @organization_assembly_types ||= AssembliesType.where(organization: current_organization).joins(:assemblies).where(
          decidim_assemblies: { id: search.result.unscope(where: :decidim_assemblies_type_id).parent_assemblies }
        ).distinct&.map { |type| [translated_attribute(type.title), type.id] }
      end
    end
  end
end
