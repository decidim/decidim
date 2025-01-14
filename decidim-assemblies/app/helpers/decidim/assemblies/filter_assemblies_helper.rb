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
        items = [
          { method: :with_any_type, collection: filter_types_values, label: t("decidim.assemblies.assemblies.filters.type"), id: "type" }
        ]

        available_taxonomy_filters.find_each do |taxonomy_filter|
          items.append(method: "with_any_taxonomies[#{taxonomy_filter.root_taxonomy_id}]",
                       collection: filter_taxonomy_values_for(taxonomy_filter),
                       label: decidim_sanitize_translated(taxonomy_filter.name),
                       id: "taxonomy")
        end

        items.reject { |item| item[:collection].blank? }
      end

      def available_taxonomy_filters
        Decidim::TaxonomyFilter.for(current_organization).for_manifest(:assemblies)
      end
    end
  end
end
