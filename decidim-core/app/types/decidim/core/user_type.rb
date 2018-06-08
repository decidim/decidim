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

      field :name, !types.String, "The user's name"

      field :nickname, !types.String, "The user's nickname" do
        resolve ->(obj, _args, _ctx) { UserPresenter.new(obj).nickname }
      end

      field :avatarUrl, !types.String, "The user's avatar url" do
        resolve ->(obj, _args, _ctx) { UserPresenter.new(obj).avatar_url(:thumb) }
      end

      field :profilePath, !types.String, "The user's profile url" do
        resolve ->(obj, _args, _ctx) { UserPresenter.new(obj).profile_path }
      end

      field :organizationName, !types.String, "The user's organization name" do
        resolve ->(obj, _args, _ctx) { obj.organization.name }
      end

      field :deleted, !types.Boolean, "Whether the user's account has been deleted or not" do
        resolve ->(obj, _args, _ctx) { UserPresenter.new(obj).deleted? }
      end

      field :badge, !types.String, "A badge for the user group" do
        resolve ->(obj, _args, _ctx) { UserPresenter.new(obj).badge }
      end
    end
  end
end
