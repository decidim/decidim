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
        attribute :response_options, Array[ResponseOptionForm]
        attribute :display_conditions, Array[DisplayConditionForm]
        attribute :matrix_rows, Array[QuestionMatrixRowForm]
        attribute :max_choices, Integer
        attribute :max_characters, Integer, default: 0
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String
        translatable_attribute :description, String

        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :question_type, inclusion: { in: Decidim::Forms::Question::TYPES }
        validates :max_choices, numericality: { only_integer: true, greater_than: 1, less_than_or_equal_to: ->(form) { form.number_of_options } }, allow_blank: true
        validates :max_characters, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        validates :body, translatable_presence: true, if: :requires_body?
        validates :matrix_rows, presence: true, if: :matrix?
        validates :response_options, presence: true, if: :matrix?

        def to_param
          return id if id.present?

          "questionnaire-question-id"
        end

        def number_of_options
          response_options.size
        end

        def separator?
          question_type == Decidim::Forms::Question::SEPARATOR_TYPE
        end

        def title_and_description?
          question_type == Decidim::Forms::Question::TITLE_AND_DESCRIPTION_TYPE
        end

        def matrix_rows_by_position
          matrix_rows.sort do |a, b|
            if a.position && b.position
              a.position <=> b.position
            elsif a.position
              -1
            elsif b.position
              1
            else
              0
            end
          end
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
