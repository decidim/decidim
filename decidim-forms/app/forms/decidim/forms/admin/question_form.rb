# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaire questions from Decidim's admin panel.
      class QuestionForm < Decidim::Form
        include TranslatableAttributes

        attribute :position, Integer
        attribute :mandatory, Boolean, default: false
        attribute :question_type, String
        attribute :answer_options, Array[AnswerOptionForm]
        attribute :matrix_rows, Array[QuestionMatrixRowForm]
        attribute :max_choices, Integer
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String
        translatable_attribute :description, String

        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :question_type, inclusion: { in: Decidim::Forms::Question::TYPES }
        validates :max_choices, numericality: { only_integer: true, greater_than: 1, less_than_or_equal_to: ->(form) { form.number_of_options } }, allow_blank: true
        validates :body, translatable_presence: true, if: :requires_body?
        validates :matrix_rows, presence: true, if: :matrix?
        validates :answer_options, presence: true, if: :matrix?

        def to_param
          return id if id.present?

          "questionnaire-question-id"
        end

        def number_of_options
          answer_options.size
        end

        def separator?
          question_type == Decidim::Forms::Question::SEPARATOR_TYPE
        end

        private

        def matrix?
          question_type == "matrix_single" || question_type == "matrix_multiple"
        end

        def requires_body?
          return false if separator?

          !deleted
        end
      end
    end
  end
end
