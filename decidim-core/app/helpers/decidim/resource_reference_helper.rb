# frozen_string_literal: true

module Decidim
  # Helper to print resource references.
  module ResourceReferenceHelper
    # Displays the localized reference for the given resource.
    #
    # resource - the Resource that has the reference to display.
    # options - An optional hash of options
    #         * class: A string of extra css classes
    #
    # Returns a String.
    def resource_reference(resource, options = {})
      return unless resource.respond_to?(:reference) && resource.reference.present?

      "<div class='tech-info #{options[:class]}'>#{localized_reference(resource.reference)}</div>".html_safe
    end

    private

    def localized_reference(reference)
      I18n.t("reference", reference:, scope: "decidim.shared.reference")
    end
  end
end
