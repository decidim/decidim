# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User.
    class UserType < Decidim::Api::Types::BaseObject
      description "A user"

      implements Decidim::Core::AuthorInterface

      field :avatar_url, GraphQL::Types::String, "The user's avatar url", null: false
      field :badge, GraphQL::Types::String, "A badge for the user group", null: false
      field :deleted, GraphQL::Types::Boolean, "Whether the user's account has been deleted or not", null: false
      field :direct_messages_enabled, GraphQL::Types::String,
            null: false,
            description: ["If the user making the request is logged in, it will return whether this recipient accepts a conversation or not.",
                          " It will return false for non-logged requests."].join
      field :groups, [Decidim::Core::UserGroupType, { null: true }], "Groups where this user belongs", null: false, method: :accepted_user_groups
      field :id, GraphQL::Types::ID, "The user's id", null: false
      field :name, GraphQL::Types::String, "The user's name", null: false
      field :nickname, GraphQL::Types::String, "The user's nickname", null: false
      field :organization_name, Decidim::Core::TranslatedFieldType, "The user's organization name", null: false
      field :profile_path, GraphQL::Types::String, "The user's profile url", null: false

      def nickname
        object.presenter.nickname
      end

      def avatar_url
        object.presenter.avatar_url(:thumb)
      end

      def profile_path
        object.presenter.profile_path
      end

      def direct_messages_enabled
        object.presenter.direct_messages_enabled?(context.to_h)
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

      def self.authorized?(object, context)
        super && object.confirmed? && !object.blocked? && !object.deleted?
      end
    end
  end
end
