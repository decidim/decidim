# frozen_string_literal: true

module Decidim
  # Represents the association between a taxonomy and a filterable entity within the system.
  class TaxonomyFilterItem < ApplicationRecord
    belongs_to :taxonomy_filter,
               class_name: "Decidim::TaxonomyFilter",
               counter_cache: :filter_items_count,
               inverse_of: :filter_items

    belongs_to :taxonomy_item,
               class_name: "Decidim::Taxonomy",
               counter_cache: :filter_items_count,
               inverse_of: :taxonomy_filter_items

    validate :taxonomy_item_is_not_root
    validate :taxonomy_item_is_child_of_taxonomy_filter_root

    private

    def taxonomy_item_is_not_root
      return unless taxonomy_item&.root?

      errors.add(:taxonomy_item, :invalid)
    end

    def taxonomy_item_is_child_of_taxonomy_filter_root
      return if taxonomy_item&.root_taxonomy == taxonomy_filter&.root_taxonomy

      errors.add(:taxonomy_item, :invalid)
    end
  end
end
