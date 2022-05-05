# frozen_string_literal: true

module Decidim
  # Helper that provides convenient methods to deal with translated attributes.
  module TranslationsHelper
    include Decidim::TranslatableAttributes

    # Public: Creates a translation for each available language in the list
    # given a translation key.
    #
    # key     - The key to translate.
    # locales - A list of locales to scope the translations to. Picks up all the
    #           available locales by default.
    # options - Any other option to delegate to the individual I18n.t calls
    #
    # Returns a Hash with the locales as keys and the translations as values.
    def multi_translation(key, locales = Decidim.available_locales, **options)
      locales.each_with_object({}) do |locale, result|
        I18n.with_locale(locale) do
          result[locale.to_sym] = I18n.t(key, **options)
        end
      end
    end

    # Public: Creates an translation for each available language in the list
    # so empty fields still have the correct format.
    #
    # locales - A list of locales to scope the translations to. Picks up all the
    #           available locales by default.
    #
    # Returns a Hash with the locales as keys and the empty strings as values.
    def empty_translatable(locales = Decidim.available_locales)
      locales.each_with_object({}) do |locale, result|
        result[locale.to_s] = ""
      end
    end

    # Public: Creates a translation for each available language in the list with
    # the given value so empty fields still have the correct format. If the
    # value is not a hash, an `empty_translatable` will be returned.
    #
    # value   - A hash value containing the values for each locale. Those
    #           locales that do not have a corresponding value in the hash will
    #           be replaced by an empty string.
    # locales - A list of locales to scope the translations to. Picks up all the
    #           available locales by default.
    #
    # Returns a Hash with the locales as keys and value strings as values.
    def ensure_translatable(value, locales = Decidim.available_locales)
      return empty_translatable(locales) unless value.is_a?(Hash)

      locales.each_with_object({}) do |locale, result|
        result[locale.to_s] = value[locale.to_s] || value[locale] || ""
      end
    end

    def translated_in_current_locale?(attribute)
      return false if attribute.nil?

      attribute[I18n.locale.to_s].present?
    end

    module_function :multi_translation, :empty_translatable, :ensure_translatable, :translated_in_current_locale?
  end
end
