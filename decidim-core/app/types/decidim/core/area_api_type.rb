# frozen_string_literal: true

module Decidim
  module Core
    class AreaApiType < GraphQL::Schema::Object
      graphql_name "Area"
      description "An area."
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "Internal ID for this area"
      field :name, TranslatedFieldType, null: false, description: "The name of this area."
      field :areaType, Decidim::Core::AreaTypeType, null: true, description: "The area type of this area"

      def areaType
        object.area_type
      end
    end
  end
end
