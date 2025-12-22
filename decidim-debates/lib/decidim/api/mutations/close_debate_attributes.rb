# frozen_string_literal: true

module Decidim
  module Debates
    class CloseDebateAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "CloseDebateAttributes"
      description "Attributes for closing a debate"

      argument :conclusions, GraphQL::Types::String, description: "The conclusions for closing the debate", required: true
    end
  end
end
