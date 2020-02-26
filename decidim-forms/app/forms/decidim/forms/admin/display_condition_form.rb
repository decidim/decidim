# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaire questions from Decidim's admin panel.
      class DisplayConditionForm < Decidim::Form
        include TranslatableAttributes

        attribute :decidim_question_id, Integer
        attribute :decidim_condition_question_id, Integer
        attribute :decidim_answer_option_id, Integer
        attribute :condition_type, String
        attribute :mandatory, Boolean, default: false
        attribute :deleted, Boolean, default: false

        translatable_attribute :condition_value, String

        validates :question, presence: true, unless: :deleted
        validates :condition_question, presence: true, unless: :deleted
        validates :answer_option, presence: true, if: :answer_option_mandatory?

        validates :condition_value, translatable_presence: true, if: :condition_value_mandatory?
        validates :condition_type, presence: true, unless: :deleted

        validate :condition_question_position, unless: :deleted
        validate :valid_answer_option?, unless: :deleted

        def to_param
          return id if id.present?

          "questionnaire-display-condition-id"
        end

        def answer_options
          return [] if condition_question.blank?

          condition_question.answer_options
        end

        def questions_for_select(questionnaire, id)
          questionnaire.questions.map do |question|
            [
              question.translated_body,
              question.id,
              {
                "disabled" => (question.question_type == "sorting" || question.id == id),
                "data-type" => question.question_type
              }
            ]
          end
        end

        # Finds the Question from the given decidim_question_id
        #
        # Returns a Decidim::Forms::Question
        def question
          @question ||= Question.find_by(id: @decidim_question_id)
        end

        # Finds the Condition Question from the given decidim_condition_question_id
        #
        # Returns a Decidim::Forms::Question
        def condition_question
          @condition_question ||= Question.find_by(id: @decidim_condition_question_id)
        end

        # Finds the Answer Option from the given decidim_answer_option_id
        #
        # Returns a Decidim::Forms::AnswerOption
        def answer_option
          @answer_option ||= AnswerOption.find_by(id: @decidim_answer_option_id)
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
          return if answer_option.blank?

          errors.add(:decidim_answer_option_id, :invalid) if answer_option.question.id != decidim_condition_question_id
        end

        def condition_question_position
          return if decidim_question_id.blank?

          errors.add(:decidim_question_id, :invalid) unless question.position&.positive?
        end
      end
    end
  end
end
