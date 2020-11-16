# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User.
    class UserType < GraphQL::Schema::Object
      graphql_name "User"
      description "A user"

      interfaces [
        -> { Decidim::Core::AuthorInterface }
      ]

      field :id, ID, null: false, description: "The user's id"
      field :name, String, null: false, description: "The user's name"
      field :nickname, String, null: false, description:  "The user's nickname"
      field :avatarUrl, String, null: false, description: "The user's avatar url"
      field :profilePath, String, null: false, description: "The user's profile url"
      field :directMessagesEnabled, String, null: false, description: "If the user making the request is logged in,
       it will return whether this recipient accepts a conversation or not. It will return false for non-logged requests."
      field :organizationName, String,null: false, description:  "The user's organization name"
      field :deleted, Boolean, null: false, description: "Whether the user's account has been deleted or not"
      field :badge, String, null: false, description: "A badge for the user group"
      field :groups, [UserGroupType], null: false, description: "Groups where this user belongs"

      def nickname
        object.presenter.nickname
      end

      def avatarUrl
        object.presenter.avatar_url(:thumb)
      end

      def profilePath
        object.presenter.profile_path
      end

      def directMessagesEnabled
        object.presenter.direct_messages_enabled?(context.to_h)
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

      def groups
        object.accepted_user_groups
      end

    end
  end
end
