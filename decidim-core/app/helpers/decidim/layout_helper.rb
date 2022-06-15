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
        favicon_link_tag(current_organization.attached_uploader(:favicon).variant_url(version, host: current_organization.host), sizes: "#{size}x#{size}")
      end)
    end

    def apple_favicon
      icon_image = current_organization.attached_uploader(:favicon).variant_url(:medium, host: current_organization.host)
      return unless icon_image

      favicon_link_tag(icon_image, rel: "apple-touch-icon", type: "image/png")
    end

    def legacy_favicon
      icon_image = current_organization.attached_uploader(:favicon).variant_url(:small, host: current_organization.host)
      return unless icon_image

      favicon_link_tag(icon_image.gsub(".png", ".ico"), rel: "icon", sizes: "any", type: nil)
    end

    def redesigned_icon(name, options = {})
      default_html_properties = {
        "width" => "1em",
        "height" => "1em",
        "role" => "img",
        "aria-hidden" => "true"
      }

      html_properties = options.with_indifferent_access.transform_keys(&:dasherize).slice("width", "height", "aria-label", "role", "aria-hidden", "class")
      html_properties = default_html_properties.merge(html_properties)

      href = Decidim.cors_enabled ? "" : asset_pack_path("media/images/remixicon.symbol.svg")

      content_tag :svg, html_properties do
        content_tag :use, nil, "href" => "#{href}#ri-#{name}"
      end
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
    def legacy_icon(name, options = {})
      options = options.with_indifferent_access
      html_properties = {}

      html_properties["width"] = options[:width]
      html_properties["height"] = options[:height]
      html_properties["aria-label"] = options[:aria_label] || options[:"aria-label"]
      html_properties["role"] = options[:role] || "img"
      html_properties["aria-hidden"] = options[:aria_hidden] || options[:"aria-hidden"]

      html_properties["class"] = (["icon--#{name}"] + _icon_classes(options)).join(" ")

      title = options["title"] || html_properties["aria-label"]
      if title.blank? && html_properties["role"] == "img"
        # This will make the accessibility audit tools happy as with the "img"
        # role, the alternative text (aria-label) and title are required for the
        # element. This will also force the SVG to be hidden because otherwise
        # the screen reader would announce the icon name which can be in
        # different language (English) than the page language which is not
        # allowed.
        title = name
        html_properties["aria-label"] = title
        html_properties["aria-hidden"] = true
      end

      href = Decidim.cors_enabled ? "" : asset_pack_path("media/images/icons.svg")

      content_tag :svg, html_properties do
        inner = content_tag :title, title
        inner += content_tag :use, nil, "href" => "#{href}#icon-#{name}"

        inner
      end
    end

    def icon(*args)
      redesign_enabled? ? redesigned_icon(*args) : legacy_icon(*args)
    end

    def arrow_link(text, url, args = {})
      content_tag :a, href: url, class: "arrow-link #{args.with_indifferent_access[:class]}" do
        inner = text
        inner += redesigned_icon("arrow-right-line", class: "fill-current")
        inner.html_safe
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
        asset = File.read(application_path(path))
        asset.gsub("<svg ", "<svg#{tag_builder.tag_options(attributes)} ").html_safe
      else
        image_pack_tag(path, class: classes.join(" "), style: "display: none")
      end
    end

    def application_path(path)
      img_path = asset_pack_path(path)
      img_path = URI(img_path).path if Decidim.cors_enabled
      Rails.root.join("public/#{img_path}")
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

      controller.view_context.render partial: "decidim/shared/extended_navigation_bar", locals: {
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
