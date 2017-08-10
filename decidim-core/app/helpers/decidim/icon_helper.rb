# frozen_string_literal: true

module Decidim
  # Helpers related to icons
  module IconHelper
    # Public: Returns an icon given an instance of a Feature. It defaults to
    # a question mark when no icon is found.
    #
    # feature - The feature to generate the icon for.
    #
    # Returns an HTML tag with the icon.
    def feature_icon(feature)
      feature_manifest_icon(feature.manifest)
    end

    # Public: Returns an icon given an instance of a Feature Manifest. It defaults to
    # a question mark when no icon is found.
    #
    # feature_manifest - The feature manifest to generate the icon for.
    #
    # Returns an HTML tag with the icon.
    def feature_manifest_icon(feature_manifest)
      if feature_manifest.icon
        external_icon feature_manifest.icon
      else
        icon "question-mark"
      end
    end
  end
end
