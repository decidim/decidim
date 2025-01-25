# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies filters.
    module FilterAssembliesHelper
      include Decidim::CheckBoxesTreeHelper

      def filter_sections
        items = []

        available_taxonomy_filters.find_each do |taxonomy_filter|
          items.append(method: :with_any_taxonomies,
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
