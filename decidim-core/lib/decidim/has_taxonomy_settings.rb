# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasTaxonomySettings
    extend ActiveSupport::Concern

    included do
      after_save :update_components_counter_cache
      after_destroy :update_components_counter_cache

      def has_taxonomy_settings?
        settings.respond_to?(:taxonomy_filters)
      end

      def available_taxonomy_filters
        return Decidim::TaxonomyFilter.none unless has_taxonomy_settings?

        @available_taxonomy_filters ||= Decidim::TaxonomyFilter.for(organization).where(id: settings.taxonomy_filters)
      end

      def available_root_taxonomies
        return Decidim::Taxonomy.none unless has_taxonomy_settings?

        @available_root_taxonomies ||= organization.taxonomies.roots.where(id: available_taxonomy_filters.map(&:root_taxonomy_id))
      end

      def available_taxonomy_ids
        return [] unless has_taxonomy_settings?

        @available_taxonomy_ids ||= Decidim::TaxonomyFilterItem.where(
          taxonomy_filter_id: available_taxonomy_filters.where(id: settings.taxonomy_filters).pluck(:id)
        ).pluck(:taxonomy_item_id)
      end

      def update_components_counter_cache
        return unless has_taxonomy_settings?

        current_filters = attribute("settings")&.dig("global", "taxonomy_filters") || []
        previous_filters = attribute_previously_was("settings")&.dig("global", "taxonomy_filters") || []

        Decidim::TaxonomyFilter.for(organization).where(id: (current_filters + previous_filters)).each(&:update_components_count)
      end
    end
  end
end
