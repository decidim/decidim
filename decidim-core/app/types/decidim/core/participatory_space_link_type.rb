# frozen_string_literal: true

module Decidim
  module Core
    ParticipatorySpaceLinkType = GraphQL::ObjectType.define do
      name "ParticipatorySpaceLink"
      description "A link representation between participatory spaces"

      field :id, !types.ID, "The id of this participatory space link"
      field :fromType, !types.String, "The origin participatory space type for this participatory space link", property: :from_type
      field :toType, !types.String, "The destination participatory space type for this participatory space link", property: :to_type
      field :name, !types.String, "The name (purpose) of this participatory space link"
      field :participatorySpace, !ParticipatorySpaceInterface do
        description "The linked participatory space (polymorphic)"
        resolve ->(link, _args, _ctx) {
          manifest_name = link.name.partition("included_").last
          object_class = "Decidim::#{manifest_name.classify}"
          return link.to if link.to_type == object_class
          return link.from if link.from_type == object_class
        }
      end
    end
  end
end
