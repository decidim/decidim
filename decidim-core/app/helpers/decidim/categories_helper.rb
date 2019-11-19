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

    def categories_nested_dropdown(scope)
      sorted_main_categories = scope.first_class.includes(:subcategories).sort_by do |category|
        translated_attribute(category.name, category.participatory_space.organization)
      end

       template = ""
      sorted_main_categories.flat_map do |category|
        if category.subcategories.empty?
          template += content_tag(:li, class: "category") do
            link_to(q: ransak_params_for_query(category_id_eq: category.id)) do
              translated_attribute(category.name, category.participatory_space.organization)
            end
          end
        else
          sorted_subcategories = category.subcategories.sort_by do |subcategory|
            translated_attribute(subcategory.name, subcategory.participatory_space.organization)
          end

           template += content_tag(:li, class: "is-dropdown-submenu-parent") do
            nested_template = ""
            nested_template += link_to(q: ransak_params_for_query(category_id_eq: category.id)) do
              translated_attribute(category.name, category.participatory_space.organization)
            end
            nested_template += content_tag(:ul, class: "nested vertical menu") do
              nested_children = ""
              sorted_subcategories.each do |subcategory|
                nested_children += content_tag(:li, class: "subcategory") do
                  link_to(q: ransak_params_for_query(category_id_eq: subcategory.id)) do
                    translated_attribute(subcategory.name, subcategory.participatory_space.organization)
                  end
                end
              end
              nested_children.html_safe
            end
            nested_template.html_safe
          end
        end
      end
      template.html_safe
    end
  end
end
