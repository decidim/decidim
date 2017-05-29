# frozen_string_literal: true

module Decidim
  # A Helper to render language names in their own language.
  module LanguageChooserHelper
    # Gets the name of the given locale, in that language.
    #
    # Example:
    #
    #   locale_name(:es) => "Castellano"
    #
    # locale - a String representing the symbol of the locale. It will usually be 2 letters.
    #
    # Returns a String.
    def locale_name(locale)
      I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
    end
  end
end
