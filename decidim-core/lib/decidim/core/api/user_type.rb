# frozen_string_literal: true

module Decidim
  # This type represents a User.
  UserType = GraphQL::ObjectType.define do
    name "User"
    description "A user"

    interfaces [
      Decidim::AuthorInterface
    ]

    field :name, !types.String, "The user's name"

    field :avatarUrl, !types.String, "The user's avatar url" do
      resolve ->(obj, _args, _ctx) { obj.avatar.url }
    end

    field :organizationName, !types.String, "The user's organization name" do
      resolve ->(obj, _args, _ctx) { obj.organization.name }
    end

    field :isVerified, !types.Boolean, "Whether the author is verified or not" do
      resolve ->(_obj, _args, _ctx) { false }
    end

    field :deleted, !types.Boolean, "Whether the user's account has been deleted or not", property: :deleted?

    field :isUser, !types.Boolean, "User groups are not users" do
      resolve ->(_obj, _args, _ctx) { true }
    end
  end
end
