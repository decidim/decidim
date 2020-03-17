# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a UserGroup
    UserGroupType = GraphQL::ObjectType.define do
      name "UserGroup"
      description "A user group"

      interfaces [
        -> { Decidim::Core::AuthorInterface }
      ]

      field :id, !types.ID, "The user group's id"

      field :name, !types.String, "The user group's name"

      field :nickname, !types.String, "The user group nickname" do
        resolve ->(group, _args, _ctx) { group.presenter.nickname }
      end

      field :avatarUrl, !types.String, "The user's avatar url" do
        resolve ->(group, _args, _ctx) { group.presenter.avatar_url }
      end

      field :profilePath, !types.String, "The user group's profile url" do
        resolve ->(group, _args, _ctx) { group.presenter.profile_path }
      end

      field :disabledNotifications, !types.String, "The user group's disabled notifications status" do
        resolve ->(user, _args, _ctx) { user.presenter.disabled_notifications }
      end

      field :organizationName, !types.String, "The user group's organization name" do
        resolve ->(group, _args, _ctx) { group.organization.name }
      end

      field :deleted, !types.Boolean, "Whether the user group's has been deleted or not" do
        resolve ->(group, _args, _ctx) { group.presenter.deleted? }
      end

      field :badge, !types.String, "A badge for the user group" do
        resolve ->(group, _args, _ctx) { group.presenter.badge }
      end

      field :members, !types[UserType], "Members of this group" do
        resolve ->(group, _args, _ctx) { group.accepted_users }
      end

      field :membersCount, !types.Int, "Number of members in this group" do
        resolve ->(group, _args, _ctx) { group.accepted_memberships.count }
      end
    end
  end
end
