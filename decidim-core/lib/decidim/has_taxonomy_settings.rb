# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasTaxonomySettings
    extend ActiveSupport::Concern

    included do
      def has_taxonomy_settings?
        settings.respond_to?(:taxonomy_filters) && settings.taxonomy_filters.present?
      end

      def available_taxonomy_filters
        return [] unless has_taxonomy_settings?

        @available_taxonomy_filters ||= settings.taxonomy_filters.filter_map do |id|
          Decidim::TaxonomyFilter.find_by(id:)
        end
      end

      def available_root_taxonomies
        return [] unless has_taxonomy_settings?

        Decidim::Taxonomy.roots.where(id: available_taxonomy_filters.map(&:root_taxonomy_id))
      end

      def available_taxonomy_ids
        return [] unless has_taxonomy_settings?

        Decidim::TaxonomyFilterItem.where(taxonomy_filter_id: settings.taxonomy_filters).pluck(:taxonomy_item_id)
      end
    end
  end
end
