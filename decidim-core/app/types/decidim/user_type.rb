# frozen_string_literal: true
module Decidim
  # This type represents a User.
  UserType = GraphQL::ObjectType.define do
    name "User"
    description "A user"

    interfaces [
      Decidim::Api::AuthorInterface
    ]

    field :name, !types.String, "The user's name"

    field :avatarUrl, !types.String, "The user's avatar url" do
      resolve ->(obj, _args, _ctx) { obj.avatar.url }
    end

    field :verifiedUserGroups, !types[UserGroupType], "The user's verified user groups" do
      resolve ->(obj, _args, _ctx) { obj.user_groups.verified }
    end
  end
end
