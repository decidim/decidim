# frozen_string_literal: true

module Decidim
  module Admin
    module IconLinkHelper
      # This helper adds the necessary boilerplate for the admin icon links.
      #
      # icon_name - A String representing the icon name from Iconic
      #             http://useiconic.com/open
      # link      - The path or url where the link should point to.
      # title     - A String that will be shown when hovering the icon.
      # options   - An optional Hash containing extra data for the link:
      #             method - Symbol of HTTP verb. Supported verbs are :post, :get, :delete, :patch, and :put.
      #             class  - Any extra class that will be added to the link.
      #             data   - This option can be used to add custom data attributes.
      #
      def icon_link_to(icon_name, link, title, options = {})
        link_to(link,
                method: options[:method],
                class: "action-icon #{options[:class]}",
                data: options[:data] || {},
                title:,
                target: options[:target]) do
          content_tag(:span, data: { tooltip: true, disable_hover: false, click_open: false },
                             title:) do
            icon(icon_name, aria_label: title, role: "img")
          end
        end
      end
    end
  end
end
