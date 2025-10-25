# frozen_string_literal: true

module Decidim
  module Debates
    class UpdateDebateAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "DebateAttributes"
      description "Attributes of a debate"

      argument :title, GraphQL::Types::String, description: "The title for this debate", required: false
      argument :description, GraphQL::Types::String, description: "The description for this debate", required: false
      argument :taxonomy_ids, [GraphQL::Types::ID], description: "The taxonomy IDs for this debate", required: false
    end
  end
end
