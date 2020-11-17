# frozen_string_literal: true

module Decidim
  module Core
    class AreaTypeType < GraphQL::Schema::Object
      graphql_name "AreaType"
      description "An area type."

      field :id, ID, null: false, description: "Internal ID for this area type"
      field :name, TranslatedFieldType, null: false, description: "The name of this area type."
      field :plural, TranslatedFieldType, null: false, description: "The plural name of this area type"
    end
  end
end
