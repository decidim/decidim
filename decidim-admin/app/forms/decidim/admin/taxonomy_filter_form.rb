# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update areas.
    class TaxonomyFilterForm < Form
      include TranslatableAttributes

      attribute :root_taxonomy_id, Integer

      attribute :taxonomy_items, Array

      mimic :taxonomy_filter

      validates :root_taxonomy_id, :taxonomy_items, presence: true
      validate :valid_taxonomy_items

      def taxonomy_items
        super.compact_blank
      end

      def space_manifest
        context[:participatory_space_manifest]
      end

      def filter_items
        taxonomy_items.map do |item|
          Decidim::TaxonomyFilterItem.new(taxonomy_item_id: item)
        end
      end

      def items_collection
        return [] unless root_taxonomy

        @items_collection ||= map_items_collection(root_taxonomy)
      end

      def root_taxonomy
        @root_taxonomy ||= current_organization.taxonomies.find_by(id: root_taxonomy_id)
      end

      private

      def map_items_collection(taxonomy)
        taxonomy.children.map do |item|
          OpenStruct.new(
            name: translated_attribute(item.name),
            value: item.id,
            children: map_items_collection(item)
          )
        end
      end

      def valid_taxonomy_items
        return if taxonomy_items.all? do |item|
          root_taxonomy.all_children.map(&:id).include?(item.to_i)
        end

        errors.add(:taxonomy_items, :invalid)
      end
    end
  end
end
