# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a User.
    class UserType < GraphQL::Schema::Object
      graphql_name "User"
      description "A user"

      implements Decidim::Core::AuthorInterface

      field :id, ID, null: false, description: "The user's id"
      field :directMessagesEnabled, String, null: false, description: "If the user making the request is logged in,
      #  it will return whether this recipient accepts a conversation or not. It will return false for non-logged requests." do
        def resolve_field(object, args, context)
          object.presenter.direct_messages_enabled?(context.to_h)
        end
      end
      field :groups, [UserGroupType], null: false, description: "Groups where this user belongs"do
        def resolve_field(object, args, context)
          object.accepted_user_groups
        end
      end
    end
  end
end
