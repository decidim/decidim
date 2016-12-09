# frozen_string_literal: true
module Decidim
  module Api
    # This type represents a localized string in a single language.
    LocalizedStringType = GraphQL::ObjectType.define do
      name "LocalizedStringField"
      description "Represents a particular translation of a LocalizedStringType"

      field :locale, !types.String, "The standard locale of this translation."
      field :text, types.String, "The content of this translation."
    end
  end
end
