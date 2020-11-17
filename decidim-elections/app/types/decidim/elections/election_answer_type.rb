# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an answer to an election question.
    # The name is different from the model because to enforce consistency with Question type name.
    class ElectionAnswerType < GraphQL::Schema::Object
      graphql_name "ElectionAnswer"
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TraceableInterface

      description "An answer for an election's question"

      field :id, ID, null: false, description: "The internal ID of this answer"
      field :title, Decidim::Core::TranslatedFieldType, null: false, description: "The title for this answer"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description for this answer"
      field :weight, Int, null: true, description: "The ordering weight for this answer"

      field :proposals, [Decidim::Proposals::ProposalType], null: true, description: "The proposals related to this answer"
    end
  end
end
