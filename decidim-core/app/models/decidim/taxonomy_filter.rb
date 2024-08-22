# frozen_string_literal: true

module Decidim
  # Represents the association between a taxonomy and a filterable entity within the system.
  class TaxonomyFilter < ApplicationRecord
    belongs_to :root_taxonomy,
               class_name: "Decidim::Taxonomy",
               counter_cache: :filters_count,
               inverse_of: :taxonomy_filters

    has_many :filter_items,
             class_name: "Decidim::TaxonomyFilterItem",
             inverse_of: :taxonomy_filter,
             dependent: :destroy

    validate :root_taxonomy_is_root
    validate :space_manifest_is_registered

    delegate :name, to: :root_taxonomy

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::TaxonomyFilterPresenter
    end

    def self.for(space_manifest)
      where(space_manifest:)
    end

    private

    def root_taxonomy_is_root
      return if root_taxonomy&.root?

      errors.add(:root_taxonomy, :invalid)
    end

    def space_manifest_is_registered
      return if Decidim.participatory_space_manifests.find { |manifest| manifest.name == space_manifest&.to_sym }

      errors.add(:space_manifest, :invalid)
    end
  end
end
