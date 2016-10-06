# frozen_string_literal: true
module Decidim
  # Helper that provides convenient methods to deal with translated attributes.
  module TranslationsHelper
    # Public: Returns the translation of an attribute using the current locale,
    # if available.
    #
    # attribute - A Hash where keys (strings) are locales, and their values are
    #             the translation for each locale.
    #
    # Returns a String with the translation.
    def translated_attribute(attribute)
      attribute.try(:[], I18n.locale.to_s)
    end
  end
end
