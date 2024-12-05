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

    scope :for, ->(space_manifest) { where(space_manifest:) }
    scope :space_filters, -> { where(space_filter: true) }

    # Returns the presenter class for this log.
    #
    # log - A Decidim::Log instance.
    #
    # Returns a Decidim::AdminLog::TaxonomyFilterPresenter class
    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::TaxonomyFilterPresenter
    end

    # Public name for this filter, defaults to the root taxonomy name.
    def name
      return root_taxonomy.name if super&.compact_blank.blank?

      super
    end

    # Internal name for this filter, defaults to the root taxonomy name.
    def internal_name
      return root_taxonomy.name if super&.compact_blank.blank?

      super
    end

    # Components that have this taxonomy filter enabled.
    def components
      @components ||= Decidim::Component.where("(settings->'global'->'taxonomy_filters') @> ?", "\"#{id}\"")
    end

    # A memoized taxonomy tree hash filtered according to the filter_items
    # that respects the order given by the taxonomies table.
    # The returned hash structure is:
    # {
    #  _object_id_ => {
    #    taxonomy: _object_,
    #    children: [
    #      {
    #        _sub_object_id_: {
    #          taxonomy: _sub_object_,
    #          children: [
    #    ...
    # }
    # @returns [Hash] a hash with the taxonomy tree structure.
    def taxonomies
      @taxonomies ||= taxonomy_children(root_taxonomy)
    end

    def taxonomy_children(taxonomy)
      taxonomy.children.where(id: filter_taxonomy_ids).each_with_object({}) do |child, children|
        children[child.id] = {
          taxonomy: child,
          children: taxonomy_children(child)
        }
      end
    end

    def filter_taxonomy_ids
      @filter_taxonomy_ids ||= filter_items.map(&:taxonomy_item_id)
    end

    private

    def root_taxonomy_is_root
      return if root_taxonomy&.root?

      errors.add(:root_taxonomy, :invalid)
    end

    def space_manifest_is_registered
      available_manifests = Decidim.participatory_space_manifests.map(&:name)
      return if (participatory_space_manifests.map(&:to_sym) - available_manifests).empty?

      errors.add(:participatory_space_manifests, :invalid)
    end
  end
end
