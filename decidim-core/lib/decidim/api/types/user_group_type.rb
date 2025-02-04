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
      field :avatar_url, GraphQL::Types::String, "The user's avatar url", null: false
      field :profile_path, GraphQL::Types::String, "The user group's profile url", null: false
      field :organization_name, Decidim::Core::TranslatedFieldType, "The user group's organization name", null: false
      field :deleted, GraphQL::Types::Boolean, "Whether the user group's has been deleted or not", null: false
      field :badge, GraphQL::Types::String, "A badge for the user group", null: false
      field :members, [Decidim::Core::UserType, { null: true }], "Members of this group", null: false, method: :accepted_users
      field :members_count, GraphQL::Types::Int, "Number of members in this group", null: false

      def nickname
        object.presenter.nickname
      end

      def avatar_url
        object.presenter.avatar_url
      end

      def profile_path
        object.presenter.profile_path
      end

      def organization_name
        object.organization.name
      end

      def deleted
        object.presenter.deleted?
      end

      def badge
        object.presenter.badge
      end

      def members_count
        object.accepted_memberships.count
      end

      def self.authorized?(object, context)
        super && !object.blocked?
      end
    end
  end
end
