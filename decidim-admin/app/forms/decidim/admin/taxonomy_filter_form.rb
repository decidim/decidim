# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update areas.
    class TaxonomyFilterForm < Form
      include TranslatableAttributes
      Item = Struct.new(:name, :value, :children)
      Manifest = Struct.new(:id, :name)

      attribute :root_taxonomy_id, Integer
      translatable_attribute :name, String
      translatable_attribute :internal_name, String
      attribute :participatory_space_manifests, Array, default: []
      attribute :taxonomy_items, Array

      mimic :taxonomy_filter

      validates :root_taxonomy_id, :taxonomy_items, presence: true
      validate :valid_taxonomy_items

      def map_model(model)
        self.root_taxonomy_id = model.root_taxonomy_id
        self.taxonomy_items = model.filter_items.map(&:taxonomy_item_id)
        self.name = {} if model.attributes["name"]&.compact_blank.blank?
        self.internal_name = {} if model.attributes["internal_name"]&.compact_blank.blank?
      end

      def taxonomy_items
        super.compact_blank
      end

      def participatory_space_manifests
        super.compact_blank
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

      def available_participatory_space_manifests
        @participatory_space_manifests ||= Decidim.participatory_space_manifests.map do |manifest|
          Manifest.new(
            id: manifest.name.to_s,
            name: I18n.t("decidim.admin.taxonomy_filters.space_filter_for.#{manifest.name}")
          )
        end
      end

      private

      def map_items_collection(taxonomy)
        taxonomy.children.map do |item|
          Item.new(
            name: translated_attribute(item.name),
            value: item.id,
            children: map_items_collection(item)
          )
        end
      end

      def valid_taxonomy_items
        return if taxonomy_items.all? do |item|
          next unless root_taxonomy

          root_taxonomy.all_children.map(&:id).include?(item.to_i)
        end

        errors.add(:taxonomy_items, :invalid)
      end
    end
  end
end
