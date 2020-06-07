# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User.
    UserType = GraphQL::ObjectType.define do
      name "User"
      description "A user"

      interfaces [
        -> { Decidim::Core::AuthorInterface }
      ]

      field :id, !types.ID, "The user's id"

      field :name, !types.String, "The user's name"

      field :nickname, !types.String, "The user's nickname" do
        resolve ->(user, _args, _ctx) { user.presenter.nickname }
      end

      field :avatarUrl, !types.String, "The user's avatar url" do
        resolve ->(user, _args, _ctx) { user.presenter.avatar_url(:thumb) }
      end

      field :profilePath, !types.String, "The user's profile url" do
        resolve ->(user, _args, _ctx) { user.presenter.profile_path }
      end

      field :directMessagesEnabled, !types.String, "If the user making the request is logged in,
       it will return whether this recipient accepts a conversation or not. It will return false for non-logged requests." do
        resolve ->(user, _args, ctx) { user.presenter.direct_messages_enabled?(ctx.to_h) }
      end

      field :organizationName, !types.String, "The user's organization name" do
        resolve ->(user, _args, _ctx) { user.organization.name }
      end

      field :deleted, !types.Boolean, "Whether the user's account has been deleted or not" do
        resolve ->(user, _args, _ctx) { user.presenter.deleted? }
      end

      field :badge, !types.String, "A badge for the user group" do
        resolve ->(user, _args, _ctx) { user.presenter.badge }
      end

      field :groups, !types[UserGroupType], "Groups where this user belongs" do
        resolve ->(user, _args, _ctx) { user.accepted_user_groups }
      end
    end
  end
end
