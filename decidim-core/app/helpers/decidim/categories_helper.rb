# frozen_string_literal: true

module Decidim
  # Helper for rendering Decidim::Category related stuff.
  module CategoriesHelper
    def categories_for_select(scope)
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
  end
end
