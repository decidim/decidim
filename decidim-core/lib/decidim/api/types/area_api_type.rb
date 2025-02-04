# frozen_string_literal: true

module Decidim
  module Core
    class AreaApiType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      graphql_name "Area"
      description "An area."

      field :id, GraphQL::Types::ID, "Internal ID for this area", null: false
      field :name, Decidim::Core::TranslatedFieldType, "The graphql_name of this area.", null: false
      field :area_type, Decidim::Core::AreaTypeType, "The area type of this area", null: true
    end
  end
end
