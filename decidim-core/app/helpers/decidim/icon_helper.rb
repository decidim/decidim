# frozen_string_literal: true

module Decidim
  # Helpers related to icons
  module IconHelper
    # Public: Returns an icon given an instance of a Feature. It defaults to
    # a question mark when no icon is found.
    #
    # feature - The feature to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def feature_icon(feature, options = {})
      manifest_icon(feature.manifest, options)
    end

    # Public: Returns an icon given an instance of a Manifest. It defaults to
    # a question mark when no icon is found.
    #
    # manifest - The manifest to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def manifest_icon(manifest, options = {})
      if manifest.icon
        external_icon manifest.icon, options
      else
        icon "question-mark", options
      end
    end

    # Public: Finds the correct icon for the given resource. If the resource has a
    # Feature then it uses it to find the icon, otherwise checks for the resource
    # manifest to find the icon.
    #
    # resource - The resource to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def resource_icon(resource, options = {})
      if resource.respond_to?(:feature)
        feature_icon(resource.feature, options)
      else
        manifest_icon(resource.manifest, options)
      end
    end
  end
end
