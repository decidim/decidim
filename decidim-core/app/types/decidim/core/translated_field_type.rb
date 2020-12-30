# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a translated field in multiple languages.
    class TranslatedFieldType < Decidim::Api::Types::BaseObject
      description "A translated field"

      field :locales, [String, { null: true }], description: "Lists all the locales in which this translation is available", null: true

      field :translations, [LocalizedStringType, { null: true }], null: false do
        description "All the localized strings for this translation."
        argument :locales, [String], description: "A list of locales to scope the translations to.", required: false
      end

      field :translation, String, description: "Returns a single translation given a locale.", null: true do
        argument :locale, String, "A locale to search for", required: true
      end

      def locales
        object.keys
      end

      def translation(locale: "")
        translations = object.stringify_keys
        translations[locale]
      end

      def translations(locales: [])
        translations = object.stringify_keys
        translations = translations.slice(*locales) unless locales.empty?

        translations.map { |locale, text| OpenStruct.new(locale: locale, text: text) }
      end
    end
  end
end
