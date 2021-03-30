# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents a result of an answer to an election question.
    class ElectionResultType < Decidim::Api::Types::BaseObject
      description "A voting result for an answer"

      field :id, GraphQL::Types::ID, "The internal ID of this result", null: false
      field :votes_count, GraphQL::Types::Int, "The vote count", null: false
    end
  end
end
