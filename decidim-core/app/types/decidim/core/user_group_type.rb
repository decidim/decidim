# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a UserGroup
    class UserGroupType < GraphQL::Schema::Object
      graphql_name "UserGroup"
      description "A user group"

      implements Decidim::Core::AuthorInterface

      field :id, ID, null: false, description: "The user group's id"
      field :name, String, null: false, description: "The user group's name"
      field :nickname, String, null: false, description:  "The user group nickname"
      field :avatarUrl, String, null: false, description: "The user group's avatar url"
      field :profilePath, String, null: false, description: "The user group's profile url"
      field :organizationName, String,null: false, description:  "The user group's organization name"
      field :deleted, Boolean, null: false, description: "Whether the user group's account has been deleted or not"
      field :badge, String, null: false, description: "A badge for the user group"
      field :members, [UserType], null: false, description: "Members of this group"
      field :membersCount, Int, null: false, description: "Number of members in this group"

      def nickname
        object.presenter.nickname
      end

      def avatarUrl
        object.presenter.avatar_url(:thumb)
      end

      def profilePath
        object.presenter.profile_path
      end

      def organizationName
        object.organization.name
      end

      def deleted
        object.presenter.deleted?
      end

      def badge
        object.presenter.badge
      end

      def members
        object.accepted_users
      end

      def membersCount
        object.accepted_memberships.count
      end
    end
  end
end
