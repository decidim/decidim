# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a UserGroup
    class UserGroupType < GraphQL::Schema::Object
      graphql_name "UserGroup"
      description "A user group"

      implements Decidim::Core::AuthorInterface

      field :id, ID, null: false, description: "The user group's id"
      field :members, [UserType], null: false, description: "Members of this group"do
        def resolve_field(object, args, context)
          object.accepted_users
        end
      end
      field :membersCount, Int, null: false, description: "Number of members in this group"do
        def resolve_field(object, args, context)
          object.accepted_memberships.count
        end
      end
    end
  end
end
