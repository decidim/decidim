# frozen_string_literal: true
module Decidim
  # This type represents a User.
  UserType = GraphQL::ObjectType.define do
    name "User"
    description "An user"

    field :name, types.String, "The user's name"
  end
end