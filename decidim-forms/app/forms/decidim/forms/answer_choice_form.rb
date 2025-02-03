# frozen_string_literal: true

module Decidim
  module Forms
    # This class holds a Form to save the chosen option for an answer
    class AnswerChoiceForm < Decidim::Form
      attribute :body, String
      attribute :custom_body, String
      attribute :position, Integer
      attribute :answer_option_id, Integer
      attribute :matrix_row_id, Integer

      validates :answer_option_id, presence: true

      def map_model(model)
        self.answer_option_id = model.decidim_answer_option_id
        self.matrix_row_id = model.decidim_question_matrix_row_id
      end
    end
  end
end
