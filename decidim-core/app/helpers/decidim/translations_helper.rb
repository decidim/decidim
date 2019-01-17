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
    #
    # Returns a Hash with the locales as keys and the translations as values.
    def multi_translation(key, locales = Decidim.available_locales)
      locales.each_with_object({}) do |locale, result|
        I18n.with_locale(locale) do
          result[locale.to_sym] = I18n.t(key)
        end
      end
    end

    def empty_translatable(locales = Decidim.available_locales)
      locales.each_with_object({}) do |locale, result|
        result[locale.to_s] = ''
      end
    end

    module_function :multi_translation, :empty_translatable
  end
end
