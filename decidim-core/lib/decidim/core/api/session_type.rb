# frozen_string_literal: true

module Decidim
  # This type represents the current user session.
  SessionType = GraphQL::ObjectType.define do
    name "Session"
    description "The current session"

    field :user, UserType, "The current user" do
      resolve ->(obj, _args, _ctx) { obj }
    end

    field :verifiedUserGroups, !types[!UserGroupType], "The current user verified user groups" do
      resolve ->(obj, _args, _ctx) { obj.user_groups.verified }
    end
  end
end
