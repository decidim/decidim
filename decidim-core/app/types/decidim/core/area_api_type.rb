# frozen_string_literal: true

module Decidim
  module Core
    class AreaApiType  < GraphQL::Schema::Object
      graphql_name "Area"
      description "An area."

      field :id, ID, null: false, description: "Internal ID for this area"
      field :name, TranslatedFieldType, null: false, description:  "The name of this area."
      field :areaType, Decidim::Core::AreaTypeType, null: true, description: "The area type of this area"
      field :createdAt, Decidim::Core::DateTimeType, null: false, description: "The time this assembly was created"
      field :updatedAt, Decidim::Core::DateTimeType, null: false, description: "The time this assembly was updated"

      def areaType
        object.area_type
      end

      def createdAt
        object.created_at
      end

      def updatedAt
        object.updated_at
      end

    end
  end
end
