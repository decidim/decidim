# frozen_string_literal: true

module Decidim
  module Forms
    class QuestionType < Decidim::Api::Types::BaseObject
      description "A question in a questionnaire"

      implements Decidim::Core::TimestampsInterface

      field :body, Decidim::Core::TranslatedFieldType, "What is being asked in this question.", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description of this question.", null: true
      field :id, GraphQL::Types::ID, "ID of this question", null: false
      field :mandatory, GraphQL::Types::Boolean, "Whether if this question is mandatory.", null: false
      field :matrix_rows, [QuestionMatrixRowType, { null: true }], "List of matrix rows in matrix questions.", null: true
      field :max_characters, GraphQL::Types::Int, "On questions with free text responses, maximum number of characters the response can have (0 if no limit)", null: false
      field :max_choices, GraphQL::Types::Int, "On questions with response options, maximum number of choices the user has", null: true
      field :position, GraphQL::Types::Int, "Order position of the question in the questionnaire", null: true
      field :question_type, GraphQL::Types::String, "Type of question.", null: true
      field :response_options, [ResponseOptionType, { null: true }], "List of response options in multi-choice questions.", null: false
    end
  end
end
