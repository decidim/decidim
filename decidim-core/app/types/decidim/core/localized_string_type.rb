# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a localized string in a single language.
    class LocalizedStringType < GraphQL::Schema::Object
      graphql_name "LocalizedString"
      description "Represents a particular translation of a LocalizedStringType"

      field :locale, String, null: false, description: "The standard locale of this translation."
      field :text, String, null: true, description: "The content of this translation."
    end
  end
end
