# frozen_string_literal: true

module Decidim
  module Core
    class AreaApiType < Decidim::Api::Types::BaseObject
      graphql_name "Area"
      description "An area."

      field :id, GraphQL::Types::ID, "Internal ID for this area", null: false
      field :name, Decidim::Core::TranslatedFieldType, "The graphql_name of this area.", null: false
      field :area_type, Decidim::Core::AreaTypeType, "The area type of this area", null: true
      field :created_at, Decidim::Core::DateTimeType, "The time this assembly was created", null: false
      field :updated_at, Decidim::Core::DateTimeType, "The time this assembly was updated", null: false
    end
  end
end
