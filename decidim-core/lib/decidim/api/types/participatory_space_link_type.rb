# frozen_string_literal: true

module Decidim
  module Core
    class ParticipatorySpaceLinkType < Decidim::Api::Types::BaseObject
      description "A link representation between participatory spaces"

      field :id, GraphQL::Types::ID, "The id of this participatory space link", null: false
      field :from_type, GraphQL::Types::String, "The origin participatory space type for this participatory space link", null: false
      field :to_type, GraphQL::Types::String, "The destination participatory space type for this participatory space link", null: false
      field :name, GraphQL::Types::String, "The name (purpose) of this participatory space link", null: false
      field :participatory_space, ParticipatorySpaceInterface, description: "The linked participatory space (polymorphic)", null: false

      def participatory_space
        manifest_name = object.name.partition("included_").last
        object_class = "Decidim::#{manifest_name.classify}"
        return object.to if object.to_type == object_class
        return object.from if object.from_type == object_class
      end
    end
  end
end
