# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies filters.
    module FilterAssembliesHelper
      include Decidim::CheckBoxesTreeHelper

      def assembly_types
        @assembly_types ||= AssembliesType.where(organization: current_organization).joins(:assemblies).distinct
      end

      def filter_types_values
        return if assembly_types.blank?

        type_values = assembly_types.map { |type| [type.id.to_s, translated_attribute(type.title)] }
        type_values.prepend(["", t("decidim.assemblies.assemblies.filters.names.all")])

        filter_tree_from_array(type_values)
      end

      def filter_sections
        [
          { method: :with_any_scope, collection: filter_global_scopes_values, label_scope: "decidim.shared.participatory_space_filters.filters", id: "scope" },
          { method: :with_any_area, collection: filter_areas_values, label_scope: "decidim.shared.participatory_space_filters.filters", id: "area" },
          { method: :with_any_type, collection: filter_types_values, label_scope: "decidim.assemblies.assemblies.filters", id: "type" }
        ].reject { |item| item[:collection].blank? }
      end
    end
  end
end
