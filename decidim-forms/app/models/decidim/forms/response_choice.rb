# frozen_string_literal: true

module Decidim
  module Forms
    class ResponseChoice < Forms::ApplicationRecord
      belongs_to :response,
                 class_name: "Response",
                 foreign_key: "decidim_response_id",
                 inverse_of: :choices

      belongs_to :response_option,
                 class_name: "ResponseOption",
                 foreign_key: "decidim_response_option_id",
                 inverse_of: :choices

      belongs_to :matrix_row,
                 class_name: "QuestionMatrixRow",
                 foreign_key: "decidim_question_matrix_row_id",
                 optional: true,
                 inverse_of: :choices

      validates :matrix_row, presence: true, if: -> { response.question.matrix? }
    end
  end
end
