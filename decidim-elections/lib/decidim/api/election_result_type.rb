# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents a result of an answer to an election question.
    class ElectionResultType < Decidim::Api::Types::BaseObject
      description "A voting result for an answer"

      field :id, GraphQL::Types::ID, "The internal ID of this result", null: false
      field :created_at, Decidim::Core::DateTimeType, "When this result was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this result was updated", null: true
      field :votes_count, GraphQL::Types::Int, "The vote count", null: false
      field :result_type, GraphQL::Types::String, "The result type for this result in the closure", null: true, camelize: false
      field :closure, Decidim::Elections::ClosureType, "The closure for this result", null: false
      field :answer, Decidim::Elections::ElectionAnswerType, "The answer for this result", null: false
      field :question, Decidim::Elections::ElectionQuestionType, "The question for this result", null: false
    end
  end
end
