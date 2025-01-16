# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasTaxonomySettings
    extend ActiveSupport::Concern

    included do
      after_save :update_components_counter_cache
      after_destroy :update_components_counter_cache

      def has_taxonomy_settings?
        settings.respond_to?(:taxonomy_filters) && settings.taxonomy_filters.present?
      end

      def available_taxonomy_filters
        return Decidim::TaxonomyFilter.none unless has_taxonomy_settings?

        @available_taxonomy_filters ||= Decidim::TaxonomyFilter.where(id: settings.taxonomy_filters)
      end

      def available_root_taxonomies
        return Decidim::Taxonomy.none unless has_taxonomy_settings?

        @available_root_taxonomies ||= Decidim::Taxonomy.roots.where(id: available_taxonomy_filters.map(&:root_taxonomy_id))
      end

      def available_taxonomy_ids
        return [] unless has_taxonomy_settings?

        @available_taxonomy_ids ||= Decidim::TaxonomyFilterItem.where(taxonomy_filter_id: settings.taxonomy_filters).pluck(:taxonomy_item_id)
      end

      def update_components_counter_cache
        return unless has_taxonomy_settings?

        available_taxonomy_filters.each(&:update_component_count)
      end
    end
  end
end
