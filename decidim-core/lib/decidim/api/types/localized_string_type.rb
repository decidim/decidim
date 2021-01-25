# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a localized string in a single language.
    class LocalizedStringType < Decidim::Api::Types::BaseObject
      description "Represents a particular translation of a LocalizedStringType"

      field :locale, GraphQL::Types::String, "The standard locale of this translation.", null: false
      field :text, GraphQL::Types::String, "The content of this translation.", null: true
    end
  end
end
