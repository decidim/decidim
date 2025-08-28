# frozen_string_literal: true

module Decidim
  module Forms
    class QuestionMatrixRowType < Decidim::Api::Types::BaseObject
      description "An response option for a multi-choice question in a questionnaire"

      field :body, Decidim::Core::TranslatedFieldType, "The matrix row option text.", null: false
      field :id, GraphQL::Types::ID, "ID of this matrix row option", null: false
      field :position, GraphQL::Types::Int, "The position of this matrix row option.", null: false
    end
  end
end
