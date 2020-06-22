# frozen_string_literal: true

module Decidim
  module Forms
    class AnswerChoice < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      translatable_fields :body
      belongs_to :answer,
                 class_name: "Answer",
                 foreign_key: "decidim_answer_id"

      belongs_to :answer_option,
                 class_name: "AnswerOption",
                 foreign_key: "decidim_answer_option_id"

      belongs_to :matrix_row,
                 class_name: "QuestionMatrixRow",
                 foreign_key: "decidim_question_matrix_row_id",
                 optional: true

      validates :matrix_row, presence: true, if: -> { answer.question.matrix? }
    end
  end
end
