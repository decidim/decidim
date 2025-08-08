# frozen_string_literal: true

module Decidim
  module HasTaxonomyFormAttributes
    extend ActiveSupport::Concern

    included do
      attribute :taxonomies, Array[Integer]

      validate :taxonomies_belong_to_current_organization

      # Returns the participatory space manifest for search the available filters (ie: participatory_processes, assemblies, etc)
      # To implement where this concern is included.
      def participatory_space_manifest
        raise NotImplementedError
      end

      def taxonomizations
        @taxonomizations ||= compact_taxonomies.map do |taxonomy_id|
          Decidim::Taxonomization.new(taxonomy_id:)
        end
      end

      def taxonomy_filters
        @taxonomy_filters ||= if defined?(current_component) && current_component&.settings.respond_to?(:taxonomy_filters)
                                all_taxonomy_filters.where(id: current_component.settings.taxonomy_filters)
                              else
                                all_taxonomy_filters.for_manifest(participatory_space_manifest)
                              end
      end

      def all_taxonomy_filters
        @all_taxonomy_filters ||= TaxonomyFilter.where(root_taxonomy: root_taxonomies)
      end

      def root_taxonomies
        @root_taxonomies ||= current_organization.taxonomies.roots
      end

      private

      def taxonomies_belong_to_current_organization
        return if compact_taxonomies.empty?

        Decidim::Taxonomy.where(id: compact_taxonomies).find_each do |taxonomy|
          next if taxonomy.decidim_organization_id == current_organization.id

          errors.add(:taxonomies, :invalid)
        end
      end

      def compact_taxonomies
        @compact_taxonomies ||= taxonomies.compact
      end
    end
  end
end
