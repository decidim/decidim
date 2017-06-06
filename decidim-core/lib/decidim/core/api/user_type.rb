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
      resolve ->(obj, _args, _ctx) { obj.deleted? ? obj.avatar.url : ActionController::Base.helpers.asset_path("decidim/default-avatar.svg") }
    end

    field :organizationName, !types.String, "The user's organization name" do
      resolve ->(obj, _args, _ctx) { obj.organization.name }
    end

    field :deleted, !types.Boolean, "Whether the user's account has been deleted or not" do
      resolve ->(obj, _args, _ctx) { obj.deleted? }
    end
  end
end
