# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaire questions from Decidim's admin panel.
      class QuestionConditionForm < Decidim::Form
        include TranslatableAttributes

        attribute :mandatory, Boolean, default: false
        attribute :condition_type, String
        attribute :question, Decidim::Forms::Question
        attribute :condition_question, Decidim::Forms::Question
        attribute :answer_option, Decidim::Forms::AnswerOption

        translatable_attribute :condition_value, String

        validates :question, presence: true
        validates :condition_question, presence: true
        validates :condition_type, presence: true
        validates :condition_value, translatable_presence: true, if: :condition_value_mandatory?
        validates :answer_option, presence: true, if: :answer_option_mandatory?

        validate :condition_question_position
        validate :answer_option_from_condition_question

        def to_param
          return id if id.present?

          "questionnaire-question-condition-id"
        end

        private

        def condition_value_mandatory?
          condition_type == "match"
        end
  
        def answer_option_mandatory?
          %w(equal not_equal).include?(condition_type)
        end
  
        def answer_option_from_condition_question
          return unless answer_option_mandatory?
  
          errors.add(:answer_option, :invalid) if answer_option.question.id != condition_question.id
        end
  
        def condition_question_position
          errors.add(:condition_question, :invalid) if condition_question.position > question.position
        end
      end
    end
  end
end
