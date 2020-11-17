# frozen_string_literal: true

module Decidim
  module Core
    class ParticipatorySpaceLinkType < GraphQL::Schema::Object
      graphql_name "ParticipatorySpaceLink"
      description "A link representation between participatory spaces"

      field :id, ID, null: false, description: "The id of this participatory space link"
      field :fromType, String, null: false, description: "The origin participatory space type for this participatory space link"
      field :toType, String, null: false, description: "The destination participatory space type for this participatory space link"
      field :name, String, null: false, description: "The name (purpose) of this participatory space link"
      field :participatorySpace, ParticipatorySpaceInterface, null: false, description: "The linked participatory space (polymorphic)"

      def participatorySpace
        manifest_name = object.name.partition("included_").last
        object_class = "Decidim::#{manifest_name.classify}"
        return object.to if object.to_type == object_class
        return object.from if object.from_type == object_class
      end

      def fromType
        object.from_type
      end

      def toType
        object.to_type
      end
    end
  end
end
