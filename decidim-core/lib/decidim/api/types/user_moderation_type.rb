# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User Moderation.
    class UserModerationType < Decidim::Api::Types::BaseObject
      description "A moderated user detail"

      implements Decidim::Core::TimestampsInterface

      field :about, GraphQL::Types::String, "The user's about data", null: true
      field :block_reasons, GraphQL::Types::String, "The reasons why the user was blocked", null: true
      field :blocked_at, Decidim::Core::DateTimeType, "The date at which the user was blocked", null: true
      field :blocking_user, UserType, "The user who blocked the user", null: true
      field :id, GraphQL::Types::ID, "The ID of the moderation", null: false
      field :reports, [Decidim::Core::ReportableUserType, { null: true }], "The reports for this user", null: true
      field :user_id, GraphQL::Types::ID, "The user's id", null: false, method: :decidim_user_id

      def about
        object.user.presenter.about
      end

      def block_reasons
        object.blocking.justification
      end

      def blocked_at
        object.user.blocked_at
      end

      def blocking_user
        object.blocking.blocking_user
      end
    end
  end
end
