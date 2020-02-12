# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaire questions from Decidim's admin panel.
      class DisplayConditionForm < Decidim::Form
        include TranslatableAttributes

        attribute :question_id, Integer
        attribute :condition_question_id, Integer
        attribute :answer_option_id, Integer
        attribute :condition_type, String
        attribute :mandatory, Boolean, default: false
        attribute :deleted, Boolean, default: false

        translatable_attribute :condition_value, String

        validates :question, presence: true, if: ->(form) { form.question_id.present? }
        validates :condition_question, presence: true, if: ->(form) { form.condition_question_id.present? }
        validates :answer_option, presence: true, if: ->(form) { answer_option_mandatory? && form.question_id.present? }

        validates :condition_value, translatable_presence: true, if: :condition_value_mandatory?
        validates :condition_type, presence: true

        validate :condition_question_position
        validate :valid_answer_option?

        def to_param
          return id if id.present?

          "questionnaire-display-condition-id"
        end

        def answer_options
          return [] if condition_question.blank?

          condition_question.answer_options
        end

        # Finds the Question from the given question_id/
        #
        # Returns a Decidim::Forms::Question
        def question
          @question ||= Question.find_by(id: @question_id)
        end

        # Finds the Condition Question from the given condition_question_id/
        #
        # Returns a Decidim::Forms::Question
        def condition_question
          @condition_question ||= Question.find_by(id: @condition_question_id)
        end

        # Finds the Answer Option from the given answer_option_id/
        #
        # Returns a Decidim::Forms::AnswerOption
        def answer_option
          @answer_option ||= AnswerOption.find_by(id: @answer_option_id)
        end

        private

        def condition_value_mandatory?
          !deleted && condition_type == "match"
        end

        def answer_option_mandatory?
          !deleted && %w(equal not_equal).include?(condition_type)
        end

        def valid_answer_option?
          return unless answer_option_mandatory?

          errors.add(:answer_option_id, :invalid) if answer_option.question.id != condition_question_id
        end

        def condition_question_position
          return unless condition_question_id && question_id

          errors.add(:condition_question, :invalid) if condition_question.position > question.position
        end
      end
    end
  end
end
