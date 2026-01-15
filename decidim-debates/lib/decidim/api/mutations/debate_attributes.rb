# frozen_string_literal: true

module Decidim
  module Debates
    class DebateAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "DebateAttributes"
      description "Attributes of a debate"

      argument :description, GraphQL::Types::String, description: "The description of the debate", required: true
      argument :taxonomies, [GraphQL::Types::ID], description: "Array of taxonomy IDs", required: false
      argument :title, GraphQL::Types::String, description: "The title of the debate", required: true
    end
  end
end
