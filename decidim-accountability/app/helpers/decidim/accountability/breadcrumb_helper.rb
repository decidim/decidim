# frozen_string_literal: true

module Decidim
  module Accountability
    # Helpers needed to render the navigation breadcrumbs in results.
    #
    module BreadcrumbHelper
      def progress_calculator(taxonomy_id)
        Decidim::Accountability::ResultsCalculator.new(current_component, taxonomy_id).progress
      end

      def taxonomy
        return if (taxonomy_id = params.dig(:filter, :taxonomies_part_of_contains)).blank?

        @taxonomy ||= current_organization.taxonomies.find(taxonomy_id.is_a?(Array) ? taxonomy_id.first : taxonomy_id)
      end

      def parent_taxonomies(taxonomy)
        return [] if taxonomy&.parent.blank? || taxonomy&.parent&.root?

        [*parent_taxonomies(taxonomy.parent), taxonomy.parent]
      end

      def taxonomies_hierarchy
        parent_taxonomies(taxonomy)
      end
    end
  end
end
