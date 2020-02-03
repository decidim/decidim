# frozen_string_literal: true

module Decidim
  module Core
    AreaApiType = GraphQL::ObjectType.define do
      name "Area"
      description "An area."

      field :id, !types.ID, "Internal ID for this area"
      field :name, !TranslatedFieldType, "The name of this area."
      field :areaType, Decidim::Core::AreaTypeType, "The area type of this area", property: :area_type
      field :createdAt, !Decidim::Core::DateTimeType, "The time this assembly was created", property: :created_at
      field :updatedAt, !Decidim::Core::DateTimeType, "The time this assembly was updated", property: :updated_at
    end
  end
end
