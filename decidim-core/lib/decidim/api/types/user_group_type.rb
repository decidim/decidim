# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a UserGroup
    class UserGroupType < Decidim::Api::Types::BaseObject
      description "A user group"

      implements Decidim::Core::AuthorInterface

      field :id, GraphQL::Types::ID, "The user group's id", null: false

      field :name, GraphQL::Types::String, "The user group's name", null: false

      field :nickname, GraphQL::Types::String, "The user group nickname", null: false

      def nickname
        object.presenter.nickname
      end

      field :avatar_url, GraphQL::Types::String, "The user's avatar url", null: false

      def avatar_url
        object.presenter.avatar_url
      end

      field :profile_path, GraphQL::Types::String, "The user group's profile url", null: false

      def profile_path
        object.presenter.profile_path
      end

      field :organization_name, GraphQL::Types::String, "The user group's organization name", null: false

      def organization_name
        object.organization.name
      end

      field :deleted, GraphQL::Types::Boolean, "Whether the user group's has been deleted or not", null: false

      def deleted
        object.presenter.deleted?
      end

      field :badge, GraphQL::Types::String, "A badge for the user group", null: false

      def badge
        object.presenter.badge
      end

      field :members, [Decidim::Core::UserType, { null: true }], "Members of this group", null: false

      def members
        object.accepted_users
      end

      field :members_count, GraphQL::Types::Int, "Number of members in this group", null: false

      def members_count
        object.accepted_memberships.count
      end
    end
  end
end
