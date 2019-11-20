# frozen_string_literal: true

module Decidim
  module Admin
    module FiltersHelper
      # Produces the html for a dropdown style filter component without the text search component.
      # @param title: The text for the filter button.
      # @param submenus: A tree (Hash) with the filter options.
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

      def admin_filter_scopes_tree(organization_id)
        sorted_root_scopes = Decidim::Scope.where(decidim_organization_id: organization_id).top_level.sort_by do |scope|
          translated_attribute(scope.name)
        end

        admin_filter_scopes_subtree(sorted_root_scopes)
      end

      #----------------------------------------------------------------------
      private

      #----------------------------------------------------------------------

      def admin_filter_scopes_subtree(scopes)
        scopes.each_with_object({}) do |scope, tree|
          link = link_to(q: ransak_params_for_query(scope_id_eq: scope.id)) do
            translated_attribute(scope.name)
          end
          tree[link] = if scope.children.empty?
                         nil
                       else
                         admin_filter_scopes_subtree(scope.children)
                       end
        end
      end

      # Produces the html for the submenus of an `admin_filter`.
      # @param submenus: A tree (Hash) with the filter options. Keys are options of the dropdown, values are the sub-options that will dropdown for the given key.
      def admin_filter_submenu_options(submenus)
        content_tag(:ul, class: "nested vertical menu") do
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
  end
end
