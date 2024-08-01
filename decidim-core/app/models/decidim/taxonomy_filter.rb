# frozen_string_literal: true

module Decidim
  # Represents the association between a taxonomy and a filterable entity within the system.
  class TaxonomyFilter < ApplicationRecord
    belongs_to :taxonomy,
               class_name: "Decidim::Taxonomy",
               counter_cache: :filters_count,
               inverse_of: :taxonomy_filters

    belongs_to :filterable, polymorphic: true
  end
end
