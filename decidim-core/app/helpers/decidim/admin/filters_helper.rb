# frozen_string_literal: true

module Decidim
  module Admin
    module FiltersHelper
      def admin_filter(menu_title, submenus)
        html = <<~EOFILTER
          <li class="is-dropdown-submenu-parent">
            <a href="#" class="dropdown button">
              #{menu_title}
            </a>
            #{admin_filter_submenu_options(submenus)}
          </li>
        EOFILTER
        html.html_safe
      end

      def admin_filter_submenu_options(submenus)
        content_tag(:ul, class: "nested vertical menu") do
          if submenus.is_a?(Hash)
            submenu_html = ""
            submenus.each_pair do |key, value|
              submenu_html += if value.nil?
                                content_tag(:li, key)
                              else
                                content_tag(:li, class: "is-dropdown-submenu-parent") do
                                  html = content_tag(:a, key, href: "#")
                                  html += admin_filter_submenu_options(value)
                                  html
                                end
                              end
            end
            submenu_html.html_safe
          end
        end
      end

      def admin_filter_categories_tree(categories)
        sorted_main_categories = categories.includes(:subcategories).sort_by do |category|
          translated_attribute(category.name, category.participatory_space.organization)
        end

        tree = {}
        sorted_main_categories.each do |category|
          link = link_to(q: ransak_params_for_query(category_id_eq: category.id)) do
            translated_attribute(category.name, category.participatory_space.organization)
          end
          tree[link] = if category.subcategories.empty?
                         nil
                       else
                         admin_filter_categories_tree(category.subcategories)
                       end
        end
        tree
      end
    end
  end
end
