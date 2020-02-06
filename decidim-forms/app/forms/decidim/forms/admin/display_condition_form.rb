# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaire questions from Decidim's admin panel.
      class DisplayConditionForm < Decidim::Form
        include TranslatableAttributes

        attribute :question, Decidim::Forms::Question
        attribute :condition_question, Decidim::Forms::Question
        attribute :answer_option, Decidim::Forms::AnswerOption
        attribute :condition_type, String
        attribute :position, Integer
        attribute :mandatory, Boolean, default: false
        attribute :deleted, Boolean, default: false

        translatable_attribute :condition_value, String

        validates :question, presence: true
        validates :condition_question, presence: true
        validates :answer_option, presence: true, if: :answer_option_mandatory?
        validates :condition_value, translatable_presence: true, if: :condition_value_mandatory?
        validates :condition_type, presence: true
        validates :position, numericality: { greater_than_or_equal_to: 0 }

        validate :condition_question_position
        validate :valid_answer_option?

        delegate :answer_options, to: :condition_question

        def to_param
          return id if id.present?

          "questionnaire-display-condition-id"
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

          errors.add(:answer_option, :invalid) if answer_option&.question&.id != condition_question&.id
        end

        def condition_question_position
          return unless condition_question && question

          errors.add(:condition_question, :invalid) if condition_question.position > question.position
        end
      end
    end
  end
end
