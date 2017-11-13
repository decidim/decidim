# frozen_string_literal: true

module Decidim
  # View helpers related to the layout.
  module LayoutHelper
    # Public: Generates a set of meta tags that generate the different favicon
    # versions for an organization.
    #
    # Returns a safe String with the versions.
    def favicon
      return if current_organization.favicon.blank?

      safe_join(Decidim::OrganizationFaviconUploader::SIZES.map do |version, size|
        favicon_link_tag(current_organization.favicon.send(version).url, sizes: "#{size}x#{size}")
      end)
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
      html_properties = {}

      html_properties["width"] = options[:width]
      html_properties["height"] = options[:height]
      html_properties["aria-label"] = options[:aria_label]
      html_properties["role"] = options[:role]
      html_properties["aria-hidden"] = options[:aria_hidden]

      html_properties["class"] = (["icon--#{name}"] + _icon_classes(options)).join(" ")

      content_tag :svg, html_properties do
        content_tag :use, nil, "xlink:href" => "#{asset_path("decidim/icons.svg")}#icon-#{name}"
      end
    end

    # Outputs a SVG icon from an external file. It apparently renders an image
    # tag, but then a JS script kicks in and replaces it with an inlined SVG
    # version.
    #
    # path    - The asset's path
    #
    # Returns an <img /> tag with the SVG icon.
    def external_icon(path, options = {})
      classes = _icon_classes(options) + ["external-icon"]

      if path.split(".").last == "svg"
        asset = Rails.application.assets_manifest.find_sources(path).first
        asset.gsub("<svg ", "<svg class=\"#{classes.join(" ")}\" ").html_safe
      else
        image_tag(path, class: classes.join(" "), style: "display: none")
      end
    end

    def _icon_classes(options = {})
      classes = options[:remove_icon_class] ? [] : ["icon"]
      classes += [options[:class]]
      classes.compact
    end
  end
end
