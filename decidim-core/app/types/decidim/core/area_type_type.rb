# frozen_string_literal: true

module Decidim
  module Core
    AreaTypeType = GraphQL::ObjectType.define do
      name "AreaType"
      description "An area type."

      field :id, !types.ID, "Internal ID for this area type"
      field :name, !TranslatedFieldType, "The name of this area type."
      field :plural, !TranslatedFieldType, "The plural name of this area type"
    end
  end
end
