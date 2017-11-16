# frozen_string_literal: true

module Decidim
  # Helper that provides convenient methods to deal with translated attributes.
  module TranslationsHelper
    # Public: Returns the translation of an attribute using the current locale,
    # if available. Checks for the organization default locale as fallback.
    #
    # attribute - A Hash where keys (strings) are locales, and their values are
    #             the translation for each locale.
    #
    # Returns a String with the translation.
    def translated_attribute(attribute)
      attribute.try(:[], I18n.locale.to_s).presence ||
        attribute.try(:[], current_organization.default_locale).presence ||
        ""
    end

    # Public: Creates a translation for each available language in the list
    # given a translation key.
    #
    # key     - The key to translate.
    # locales - A list of locales to scope the translations to. Picks up all the
    #           available locales by default.
    #
    # Returns a Hash with the locales as keys and the translations as values.
    def multi_translation(key, locales = Decidim.available_locales)
      locales.each_with_object({}) do |locale, result|
        I18n.with_locale(locale) do
          result[locale.to_sym] = I18n.t(key)
        end
      end
    end
    module_function :multi_translation
  end
end
