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
      if feature.manifest.icon
        external_icon feature.manifest.icon
      else
        icon "question-mark"
      end
    end
  end
end
