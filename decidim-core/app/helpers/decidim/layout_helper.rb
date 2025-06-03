# frozen_string_literal: true

module Decidim
  # View helpers related to the layout.
  module LayoutHelper
    include Decidim::OrganizationHelper
    include Decidim::ModalHelper
    include Decidim::TooltipHelper

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
      variant = :favicon if current_organization.favicon.content_type != "image/vnd.microsoft.icon"
      icon_image = current_organization.attached_uploader(:favicon).variant_url(variant, host: current_organization.host)
      return unless icon_image

      favicon_link_tag(icon_image, rel: "icon", sizes: "any", type: nil)
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
      name = Decidim.icons.find(name)["icon"] unless options[:ignore_missing]

      default_html_properties = {
        "width" => "1em",
        "height" => "1em",
        "role" => "img",
        "aria-hidden" => "true"
      }

      html_properties = options.with_indifferent_access.transform_keys(&:dasherize).slice("width", "height", "aria-label", "role", "aria-hidden", "class", "style")
      html_properties = default_html_properties.merge(html_properties)

      if name == "wechat-line"
        html_properties = html_properties.merge({ "aria-label" => I18n.t("decidim.author.comments.other") }).reject{ |k,v| k == "aria-hidden" }
      elsif name == "heart-line"
        html_properties = html_properties.merge({ "aria-label" => I18n.t(".decidim.author.likes.other") }).reject{ |k,v| k == "aria-hidden" }
      end

      href = Decidim.cors_enabled ? "" : asset_pack_path("media/images/remixicon.symbol.svg")

      content_tag :svg, html_properties do
        content_tag :use, nil, "href" => "#{href}#ri-#{name}"
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
        icon_path = application_path(path)
        return unless icon_path

        attributes = { class: classes.join(" ") }.merge(options)
        asset = File.read(icon_path)
        asset.gsub("<svg ", "<svg#{tag_builder.tag_options(attributes)} ").html_safe
      else
        image_pack_tag(path, class: classes.join(" "), style: "display: none")
      end
    end

    def application_path(path)
      # Force the path to be returned without the protocol and host even when a
      # custom asset host has been defined. The host parameter needs to be a
      # non-nil because otherwise it will be set to the asset host at
      # ActionView::Helpers::AssetUrlHelper#compute_asset_host.
      img_path = asset_pack_path(path, host: "", protocol: :relative)
      path = Rails.public_path.join(img_path.sub(%r{^/}, ""))
      return unless File.exist?(path)

      path
    rescue ::Shakapacker::Manifest::MissingEntryError
      nil
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
        items:,
        extra_items:,
        active_item:,
        max_items:
      }
    end

    def current_user_unread_data
      return {} if current_user.blank?

      {}.tap do |d|
        d.merge!(unread_notifications: true) if current_user.notifications.any?
        d.merge!(unread_conversations: true) if current_user.unread_conversations.any?
        d.merge!(unread_items: d.present?)
      end
    end

    def current_url(params = request.parameters)
      return url_for(params) if respond_to?(:current_participatory_space) || respond_to?(:current_component)

      each_decidim_engine do |helpers|
        return helpers.url_for(params)
      rescue ActionController::UrlGenerationError
        # Continue to next engine in case the URL is not available.
      end

      main_app.url_for(params)
    rescue ActionController::UrlGenerationError
      "#{request.base_url}#{"?#{params.to_query}" unless params.empty?}"
    end

    def root_url
      return onboarding_manager.root_path if current_user&.ephemeral?

      decidim.root_url(host: current_organization.host)
    end

    private

    def each_decidim_engine
      Rails.application.railties.each do |engine|
        next unless engine.is_a?(Rails::Engine)
        next unless engine.isolated?
        next unless engine.engine_name.start_with?("decidim_")
        next unless respond_to?(engine.engine_name)

        yield public_send(engine.engine_name)
      end
      return unless respond_to?(:decidim)

      yield decidim
    end

    def tag_builder
      @tag_builder ||= ActionView::Helpers::TagHelper::TagBuilder.new(self)
    end
  end
end
