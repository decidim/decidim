# frozen_string_literal: true
module Decidim
  # View helpers related to the layout.
  module LayoutHelper
    def decidim_page_title
      if title = content_for(:title)
        "#{title} - #{current_organization.name}"
      else
        current_organization.name
      end
    end

    # Outputs an SVG-based icon.
    #
    # name    - The String with the icon name.
    # options - The Hash options used to customize the icon (default {}):
    #             :width  - The Number of width in pixels (optional).
    #             :height - The Number of height in pixels (optional).
    #             :aria_label - The String to set as aria label (optional).
    #             :aria_hidden - The Truthy value to enable aria_hidden (optional).
    #             :role - The String to set as the role (optional).
    #             :class - The String to add as a CSS class (optional).
    #
    # Returns a String.
    def icon(name, options = {})
      # Ugly hack to work around the issue of phantomjs not sending js events
      # when clicking on a SVG element.
      if Rails.env.test?
        return content_tag(:span, "?", class: "icon icon--#{name}")
      end

      html_properties = {}

      html_properties["width"] = options[:width]
      html_properties["height"] = options[:height]
      html_properties["aria-label"] = options[:aria_label]
      html_properties["role"] = options[:role]
      html_properties["aria-hidden"] = options[:aria_hidden]
      html_properties["class"] = "icon icon--#{name} #{options[:class]}"

      content_tag :svg, html_properties do
        content_tag :use, nil, "xlink:href" => "#{asset_url("decidim/icons.svg")}#icon-#{name}"
      end
    end
  end
end
