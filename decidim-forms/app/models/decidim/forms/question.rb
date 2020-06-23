# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a Question in the Decidim::Forms component.
    class Question < Forms::ApplicationRecord
      QUESTION_TYPES = %w(short_answer long_answer single_option multiple_option sorting matrix_single matrix_multiple).freeze
      SEPARATOR_TYPE = "separator"
      TYPES = (QUESTION_TYPES + [SEPARATOR_TYPE]).freeze

      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_questionnaire_id"

      has_many :matrix_rows,
               class_name: "QuestionMatrixRow",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      has_many :answer_options,
               class_name: "AnswerOption",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      validates :question_type, inclusion: { in: TYPES }

      def matrix?
        %w(matrix_single matrix_multiple).include?(question_type)
      end

      def multiple_choice?
        %w(single_option multiple_option sorting matrix_single matrix_multiple).include?(question_type)
      end

      def mandatory_body?
        mandatory? && !multiple_choice?
      end

      def mandatory_choices?
        mandatory? && multiple_choice?
      end

      def number_of_options
        answer_options.size
      end

      def separator?
        question_type.to_s == SEPARATOR_TYPE
      end
    end
  end
end
