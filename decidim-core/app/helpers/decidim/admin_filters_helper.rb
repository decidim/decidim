# frozen_string_literal: true

module Decidim
  module Admin
    module FiltersHelper
      # h= {
      #   t("actions.filter.label", scope: "decidim.admin") => [
      #     {t("proposals.filters.type", scope: "decidim.proposals") => [
      #       link_to t("proposals", scope: "decidim.proposals.application_helper.filter_type_values"), q: ransak_params_for_query(is_emendation_true: "0"),
      #       link_to t("amendments", scope: "decidim.proposals.application_helper.filter_type_values"), q: ransak_params_for_query(is_emendation_true: "1")
      #     ]}
      #   ]
      # }
      def admin_filter_option(menu_title, submenus)
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
    end

    def admin_filter_submenu_options(submenus)
      content_tag(:ul, class: "nested vertical menu") do
        if submenus.is_a?(Hash)
          content_tag(:li, class: "is-dropdown-submenu-parent") do
            html = content_tag(:a, submenus.keys.first, href: "#")
            html += admin_filter_submenu_options(submenus.values.first)
            html.html_safe
          end
        else
          submenus.collect { |opt| content_tag(:li, opt) }.join("").html_safe
        end
      end
    end
  end
end
