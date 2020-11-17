# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a translated field in multiple languages.
    class TranslatedFieldType < GraphQL::Schema::Object
      graphql_name "TranslatedField"
      description "A translated field"

      field :locales, [String], null: true, description: "Lists all the locales in which this translation is available"
      field :translations, [LocalizedStringType], null: false, description: "All the localized strings for this translation." do
        argument :locales, [String], required: false, description: "A list of locales to scope the translations to."
      end

      field :translation, String, null: true, description: "Returns a single translation given a locale." do
        argument :locale, String, required: true, description: "A locale to search for"
      end

      def translation(locale:)
        translations = object.stringify_keys
        translations[locale]
      end

      def translations(locales:)
        translations = object.stringify_keys
        translations = translations.slice(*locales) if locales

        translations.map { |locale, text| OpenStruct.new(locale: locale, text: text) }
      end

      def locales
        object.keys
      end
    end
  end
end
