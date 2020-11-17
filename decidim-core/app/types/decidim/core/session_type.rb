# frozen_string_literal: true

module Decidim
  module Core
    # This type represents the current user session.
    class SessionType < GraphQL::Schema::Object
      graphql_name "Session"
      description "The current session"

      field :user, UserType, null: true, description: "The current user"
      field :verifiedUserGroups, [UserGroupType], null: false, description: "The current user verified user groups"

      def verifiedUserGroups
        Decidim::UserGroups::ManageableUserGroups.for(object).verified
      end

      def user
        object
      end
    end
  end
end
