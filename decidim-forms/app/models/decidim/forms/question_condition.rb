# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a QuestionCondition in the Decidim::Forms component.
    class QuestionCondition < Forms::ApplicationRecord
      enum condition_type: [:answered, :not_answered, :equal, :not_equal, :match], _prefix: true

      belongs_to :question, class_name: "Question", foreign_key: "decidim_forms_question_id", inverse_of: :conditions
      belongs_to :condition_question, class_name: "Question", foreign_key: "decidim_forms_question_condition_id"
      belongs_to :answer_option, class_name: "AnswerOption", foreign_key: "decidim_forms_answer_option_id", optional: true

      validate :condition_question_position
      validate :answer_option_from_condition_question
      validates :answer_option, presence: true, if: :answer_option_mandatory?

      def fulfilled?(answer)
        case condition_type
        when "answered"
          answer.present?
        when "not_answered"
          answer.blank?
        when "equal"
          answer.choices.pluck(:decidim_answer_option_id).include?(answer_option.id)
        when "not_equal"
          !answer.choices.pluck(:decidim_answer_option_id).include?(answer_option.id)
        when "match"
          condition_value.values.any? { |value| answer.body.match?(Regexp.new(value)) }
        end
      end

      private

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
