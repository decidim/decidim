# frozen_string_literal: true

module Decidim
  module Core
    class UserEntityInputSort < BaseInputSort
      graphql_name "UserEntitySort"
      description "A type used for sorting any component parent objects"

      argument :id, GraphQL::Types::String, "Sort by ID, valid values are ASC or DESC", required: false
      argument :type,
               type: GraphQL::Types::String,
               description: "Sort by type of user entity (user or group), alphabetically, valid values are ASC or DESC",
               required: false
      argument :name,
               type: GraphQL::Types::String,
               description: "Sort by name of the user entity (user or group), alphabetically, valid values are ASC or DESC",
               required: false
      argument :nickname,
               type: GraphQL::Types::String,
               description: "Sort by nickname of the user entity (user or group), alphabetically, valid values are ASC or DESC",
               required: false
    end
  end
end
