# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an answer to an election question.
    # The name is different from the model because to enforce consistency with Question type name.
    class ElectionAnswerType < Decidim::Api::Types::BaseObject

      implements  Decidim::Core::AttachableInterface
      implements Decidim::Core::TraceableInterface

      description "An answer for an election's question"

      field :id, ID, "The internal ID of this answer", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this answer", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description for this answer", null: true
      field :weight, Integer, "The ordering weight for this answer", null: true
      field :votes_count, Integer, "The votes for this answer", null: true
      field :selected, Boolean, "Is this answer selected?", null: true

      field :proposals, [Decidim::Proposals::ProposalType, null: true], "The proposals related to this answer", null: true
    end
  end
end
