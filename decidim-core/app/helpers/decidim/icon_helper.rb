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
      feature_manifest_icon(feature.manifest, options)
    end

    # Public: Returns an icon given an instance of a Feature Manifest. It defaults to
    # a question mark when no icon is found.
    #
    # feature_manifest - The feature manifest to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def feature_manifest_icon(feature_manifest, options = {})
      if feature_manifest.icon
        external_icon feature_manifest.icon, options
      else
        icon "question-mark", options
      end
    end

    # Public: Finds the correct icon for the given resource. If the resource has a
    # Feature then it uses it to find the icon, otherwise checks for the resource
    # type to find the icon.
    #
    # resource - The resource to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def resource_icon(resource, options = {})
      if resource.respond_to?(:feature)
        feature_icon(resource.feature, options)
      else
        external_icon "decidim/participatory_processes/process.svg", options
      end
    end
  end
end
