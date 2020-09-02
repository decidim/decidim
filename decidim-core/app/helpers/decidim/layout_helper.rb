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
    #             :title - The title for the SVG element (optional, similar to alt for img)
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
      html_properties["aria-label"] = options[:aria_label] || options[:"aria-label"] || options["aria-label"]
      html_properties["role"] = options[:role] || "img"
      html_properties["aria-hidden"] = options[:aria_hidden] || options[:"aria-hidden"] || options["aria-hidden"]

      html_properties["class"] = (["icon--#{name}"] + _icon_classes(options)).join(" ")

      content_tag :svg, html_properties do
        inner = content_tag :title, options["title"] || html_properties["aria-label"]
        inner += content_tag :use, nil, role: options[:role], "href" => "#{asset_path("decidim/icons.svg")}#icon-#{name}"

        inner
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
        attributes = { class: classes.join(" ") }.merge(options)
        asset = Rails.application.assets_manifest.find_sources(path).first
        asset.gsub("<svg ", "<svg#{tag_builder.tag_options(attributes)} ").html_safe
      else
        image_tag(path, class: classes.join(" "), style: "display: none")
      end
    end

    # Allows to create role attribute according to accessibility rules
    #
    # Returns role attribute string if role option is specified
    def role(options = {})
      "role=\"#{options[:role]}\" " if options[:role]
    end

    def _icon_classes(options = {})
      classes = options[:remove_icon_class] ? [] : ["icon"]
      classes += [options[:class]]
      classes.compact
    end

    def extended_navigation_bar(items, max_items: 5)
      return unless items.any?

      extra_items = items.slice((max_items + 1)..-1) || []
      active_item = items.find { |item| item[:active] }

      render partial: "decidim/shared/extended_navigation_bar", locals: {
        items: items,
        extra_items: extra_items,
        active_item: active_item,
        max_items: max_items
      }
    end

    # Renders a view with the customizable CSS variables in two flavours:
    # 1. as a hexadecimal valid CSS color (ie: #ff0000)
    # 2. as a disassembled RGB components (ie: 255,0,0)
    #
    # Example:
    #
    # --primary: #ff0000;
    # --primary-rgb: 255,0,0
    #
    # Hexadecimal variables can be used as a normal CSS color:
    #
    # color: var(--primary)
    #
    # While the disassembled variant can be used where you need to manipulate
    # the color somehow (ie: adding a background transparency):
    #
    # background-color: rgba(var(--primary-rgb), 0.5)
    def organization_colors
      css = current_organization.colors.each.map { |k, v| "--#{k}: #{v};--#{k}-rgb: #{v[1..2].hex},#{v[3..4].hex},#{v[5..6].hex};" }.join
      render partial: "layouts/decidim/organization_colors", locals: { css: css }
    end

    private

    def tag_builder
      @tag_builder ||= ActionView::Helpers::TagHelper::TagBuilder.new(self)
    end
  end
end
