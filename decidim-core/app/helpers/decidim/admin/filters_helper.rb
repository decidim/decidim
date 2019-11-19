# frozen_string_literal: true

module Decidim
  module Admin
    module FiltersHelper

      def admin_filter(menu_title, submenus)
        html= <<~EOFILTER
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
          if submenus.kind_of?(Hash)
            content_tag(:li, class: "is-dropdown-submenu-parent") do
              html= content_tag(:a, submenus.keys.first, href: "#")
              html+= admin_filter_submenu_options(submenus.values.first)
              html.html_safe
            end
          else
            submenus.collect {|opt| content_tag(:li, opt)}.join('').html_safe
          end
        end
      end
    end
  end
end