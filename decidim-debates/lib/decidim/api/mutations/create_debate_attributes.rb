# frozen_string_literal: true

module Decidim
  module Debates
    class CreateDebateAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "DebateAttributes"
      description "Attributes of a debate"

      argument :title, GraphQL::Types::String, description: "The title of the debate", required: true
      argument :description, GraphQL::Types::String, description: "The description of the debate", required: true
      argument :taxonomy_ids, [GraphQL::Types::ID], description: "The taxonomy IDs to associate with the debate", required: false
    end
  end
end
