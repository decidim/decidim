# frozen_string_literal: true
module Decidim
  # Helper to print Feature references.
  module FeatureReferenceHelper
    # Displays the localized reference for the given feature.
    #
    # feature - the Feature that has the reference to display.
    #
    # Returns a String.
    def feature_reference(feature)
      return unless feature.reference
      @reference = feature.reference
      "<div class='reference'>#{localized_reference}</div>".html_safe
    end

    private

    def localized_reference
      I18n.t("reference", reference: @reference, scope: "decidim.shared.reference")
    end
  end
end
