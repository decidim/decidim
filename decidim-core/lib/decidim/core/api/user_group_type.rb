# frozen_string_literal: true

module Decidim
  # This type represents a UserGroup
  UserGroupType = GraphQL::ObjectType.define do
    name "UserGroup"
    description "A user group"

    interfaces [
      Decidim::AuthorInterface
    ]

    field :id, !types.ID, "The user group's id"

    field :name, !types.String, "The user group's name"

    field :avatarUrl, !types.String, "The user's avatar url" do
      resolve ->(obj, _args, _ctx) { obj.avatar.url }
    end
  end
end
