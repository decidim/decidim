# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an answer to an election question.
    # The name is different from the model because to enforce consistency with Question type name.
    ElectionAnswerType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::AttachableInterface },
        -> { Decidim::Core::TraceableInterface }
      ]

      name "ElectionAnswer"
      description "An answer for an election's question"

      field :id, !types.ID, "The internal ID of this answer"
      field :title, !Decidim::Core::TranslatedFieldType, "The title for this answer"
      field :description, Decidim::Core::TranslatedFieldType, "The description for this answer"
      field :weight, types.Int, "The ordering weight for this answer"
      field :votes_count, types.Int, "The votes for this answer"
      field :selected, types.Boolean, "Is this answer selected?"

      field :proposals, types[Decidim::Proposals::ProposalType], "The proposals related to this answer"
    end
  end
end
