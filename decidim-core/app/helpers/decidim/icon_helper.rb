# frozen_string_literal: true

module Decidim
  # Helpers related to icons
  module IconHelper
    include Decidim::LayoutHelper

    # Public: Returns an icon given an instance of a Component. It defaults to
    # a question mark when no icon is found.
    #
    # component - The component to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def component_icon(component, options = {})
      manifest_icon(component.manifest, options)
    end

    # Public: Returns an icon given an instance of a Manifest. It defaults to
    # a question mark when no icon is found.
    #
    # manifest - The manifest to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def manifest_icon(manifest, options = {})
      if manifest.respond_to?(:icon) && manifest.icon.present?
        external_icon manifest.icon, options
      else
        icon "question-mark", options
      end
    end

    # Public: Finds the correct icon for the given resource. If the resource has a
    # Component then it uses it to find the icon, otherwise checks for the resource
    # manifest to find the icon.
    #
    # resource - The resource to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def resource_icon(resource, options = {})
      if resource.instance_of?(Decidim::Comments::Comment)
        icon "chat-1-line", options
      elsif resource.respond_to?(:component) && resource.component.present?
        component_icon(resource.component, options)
      elsif resource.respond_to?(:manifest) && resource.manifest.present?
        manifest_icon(resource.manifest, options)
      elsif resource.is_a?(Decidim::User)
        icon "user-line", options
      else
        icon "notification-3-line", options
      end
    end

    def resource_type_icon(resource_type, options = {})
      icon resource_type_icon_key(resource_type), options
    end

    def resource_type_icon_key(resource_type)
      Decidim.icons.find(resource_type.to_s).icon || Decidim.icons.find("other").icon
    end

    def text_with_resource_icon(resource_name, text)
      output = ""
      output += resource_type_icon resource_name
      output += content_tag :span, text
      output.html_safe
    end
  end
end
