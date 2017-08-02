# frozen_string_literal: true

module Decidim
  # This type represents a translated field in multiple languages.
  TranslatedFieldType = GraphQL::ObjectType.define do
    name "TranslatedField"
    description "A translated field"

    field :locales do
      type types[!types.String]
      description "Lists all the locales in which this translation is available"
      resolve ->(obj, _args, _ctx) { obj.keys }
    end

    field :translations do
      type !types[!LocalizedStringType]
      description "All the localized strings for this translation."

      argument :locales do
        type types[!types.String]
        description "A list of locales to scope the translations to."
      end

      resolve lambda { |obj, args, _ctx|
        translations = obj.stringify_keys
        translations = translations.slice(*args["locales"]) if args["locales"]

        translations.map { |locale, text| OpenStruct.new(locale: locale, text: text) }
      }
    end

    field :translation do
      type types.String
      description "Returns a single translation given a locale."
      argument :locale, !types.String, "A locale to search for"

      resolve lambda { |obj, args, _ctx|
        translations = obj.stringify_keys
        translations[args["locale"]]
      }
    end
  end
end
