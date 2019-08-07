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
        resolve ->(obj, _args, _ctx) { UserGroupPresenter.new(obj).nickname }
      end

      field :avatarUrl, !types.String, "The user's avatar url" do
        resolve ->(obj, _args, _ctx) { UserGroupPresenter.new(obj).avatar_url }
      end

      field :profilePath, !types.String, "The user group's profile url" do
        resolve ->(obj, _args, _ctx) { UserGroupPresenter.new(obj).profile_path }
      end

      field :deleted, !types.Boolean, "Whether the user group's has been deleted or not" do
        resolve ->(obj, _args, _ctx) { UserGroupPresenter.new(obj).deleted? }
      end

      field :badge, !types.String, "A badge for the user group" do
        resolve ->(obj, _args, _ctx) { UserGroupPresenter.new(obj).badge }
      end
    end
  end
end
