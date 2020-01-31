# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a QuestionCondition in the Decidim::Forms component.
    class QuestionCondition < Forms::ApplicationRecord
      enum condition_types: [:answered, :not_answered, :equal, :not_equal, :match]

      belongs_to :question, class_name: "Question", foreign_key: "decidim_forms_question_id"
      belongs_to :condition_question, class_name: "Question", foreign_key: "decidim_forms_question_condition_id"
      belongs_to :answer_option, class_name: "AnswerOption", foreign_key: "decidim_forms_answer_option_id"

      validate :condition_question_position
      validates :answer_option, presence: true, if: -> { [:equal, :not_equal].include?(condition_type) }

      def fulfilled?(answer)
        case condition_type
        when :answered
          answer.present?
        when :not_answered
          answer.blank?
        when :equal
          answer.choices.pluck(:decidim_answer_option_id).include?(answer_option)
        when :not_equal
          !answer.choices.pluck(:decidim_answer_option_id).include?(answer_option)
        when :match
          condition_value.values.any? { |value| answer.body.match?(Regexp.new(value)) }
        end
      end

      private

      def condition_question_position
        errors.add(:condition_question, :invalid) if condition_question.position > question.position
      end
    end
  end
end
