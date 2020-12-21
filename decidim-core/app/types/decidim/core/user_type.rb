# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User.
    class UserType < Decidim::Api::Types::BaseObject
      description "A user"

      implements  Decidim::Core::AuthorInterface

      field :id, ID, "The user's id", null: false

      field :name, String, "The user's name", null: false

      field :nickname, String, "The user's nickname", null: false

      def nickname
        object.presenter.nickname
      end

      field :avatar_url, String, "The user's avatar url", null: false

      def avatar_url
        object.presenter.avatar_url(:thumb)
      end

      field :profile_path, String, "The user's profile url", null: false

      def profile_path
        object.presenter.profile_path
      end

      field :direct_messages_enabled, String, "If the user making the request is logged in, it will return whether this recipient accepts a conversation or not. It will return false for non-logged requests.", null: false

      def direct_messages_enabled
        object.presenter.direct_messages_enabled?(context.to_h)
      end

      field :organization_name, String, "The user's organization name", null: false

      def organization_name
        object.organization.name
      end

      field :deleted, Boolean, "Whether the user's account has been deleted or not", null: false

      def deleted
        object.presenter.deleted?
      end

      field :badge, String, "A badge for the user group", null: false

      def badge
        object.presenter.badge
      end

      field :groups, [UserGroupType, null: true], "Groups where this user belongs", null: false

      def groups
        object.accepted_user_groups
      end
    end
  end
end
