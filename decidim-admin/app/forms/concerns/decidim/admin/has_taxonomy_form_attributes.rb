# frozen_string_literal: true

module Decidim
  module Admin
    module HasTaxonomyFormAttributes
      extend ActiveSupport::Concern

      included do
        attribute :taxonomies, Array[Integer]

        validate :taxonomies_belong_to_current_organization

        def participatory_space_manifest
          raise NotImplementedError
        end

        def taxonomizations
          compact_taxonomies.map do |taxonomy_id|
            Decidim::Taxonomization.new(taxonomy_id:)
          end
        end

        def taxonomy_filters
          @taxonomy_filters ||= TaxonomyFilter.where(space_manifest: participatory_space_manifest, root_taxonomy: root_taxonomies)
        end

        def root_taxonomies
          @root_taxonomies ||= current_organization.taxonomies.where(parent_id: nil)
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
end
