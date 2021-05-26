# frozen_string_literal: true

module Decidim
  module Forms
    class QuestionType < Decidim::Api::Types::BaseObject
      description "A question in a questionnaire"

      implements Decidim::Core::TimestampsInterface

      field :id, GraphQL::Types::ID, "ID of this question", null: false
      field :body, Decidim::Core::TranslatedFieldType, "What is being asked in this question.", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description of this question.", null: true
      field :mandatory, GraphQL::Types::Boolean, "Whether if this question is mandatory.", null: false
      field :position, GraphQL::Types::Int, "Order position of the question in the questionnaire", null: true
      field :max_choices, GraphQL::Types::Int, "On questions with answer options, maximum number of choices the user has", null: true
      field :max_characters, GraphQL::Types::Int, "On questions with free text answers, maximum number of characters the answer can have (0 if no limit)", null: false
      field :question_type, GraphQL::Types::String, "Type of question.", null: true
      field :answer_options, [AnswerOptionType, { null: true }], "List of answer options in multi-choice questions.", null: false
    end
  end
end
