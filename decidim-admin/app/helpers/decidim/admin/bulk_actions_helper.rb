# frozen_string_literal: true

module Decidim
  module Admin
    module BulkActionsHelper
      # Public: Generates a select field with the categories. Only leaf categories can be set as selected.
      #
      # categories - A collection of categories.
      #
      # Returns a String.
      def bulk_categories_select(collection)
        categories = bulk_categories_for_select collection
        disabled = bulk_disabled_categories_for collection
        prompt = t("decidim.proposals.admin.proposals.index.change_category")
        select(:category, :id, options_for_select(categories, selected: [], disabled:), prompt:)
      end

      def bulk_categories_for_select(scope)
        sorted_main_categories = scope.first_class.includes(:subcategories).sort_by do |category|
          translated_attribute(category.name, category.participatory_space.organization)
        end

        sorted_main_categories.flat_map do |category|
          parent = [[translated_attribute(category.name, category.participatory_space.organization), category.id]]

          sorted_subcategories = category.subcategories.sort_by do |subcategory|
            translated_attribute(subcategory.name, subcategory.participatory_space.organization)
          end

          sorted_subcategories.each do |subcategory|
            parent << ["- #{translated_attribute(subcategory.name, subcategory.participatory_space.organization)}", subcategory.id]
          end

          parent
        end
      end

      def bulk_disabled_categories_for(scope)
        scope.first_class.joins(:subcategories).pluck(:id)
      end

      # Public: Generates a select field with the components.
      #
      # siblings - A collection of components.
      #
      # Returns a String.
      def bulk_components_select(siblings)
        components = siblings.map do |component|
          [translated_attribute(component.name, component.organization), component.id]
        end

        prompt = t("decidim.proposals.admin.proposals.index.select_component")
        select(:target_component_id, nil, options_for_select(components, selected: []), prompt:)
      end
    end
  end
end
