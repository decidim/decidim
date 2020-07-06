# frozen_string_literal: true

module Decidim
  module Forms
    # This class holds a Form to save the questionnaire answers from Decidim's public page
    class AnswerForm < Decidim::Form
      include Decidim::TranslationsHelper

      attribute :question_id, String
      attribute :body, String
      attribute :choices, Array[AnswerChoiceForm]
      attribute :matrix_choices, Array[AnswerChoiceForm]

      validates :body, presence: true, if: :mandatory_body?
      validates :selected_choices, presence: true, if: :mandatory_choices?

      validate :max_choices, if: -> { question.max_choices }
      validate :all_choices, if: -> { question.question_type == "sorting" }
      validate :min_choices, if: -> { question.matrix? && question.mandatory? }

      delegate :mandatory_body?, :mandatory_choices?, :matrix?, to: :question

      attr_writer :question

      def question
        @question ||= Decidim::Forms::Question.find(question_id)
      end

      def label(idx)
        base = "#{idx + 1}. #{translated_attribute(question.body)}"
        base += " #{mandatory_label}" if question.mandatory?
        base += " (#{max_choices_label})" if question.max_choices
        base
      end

      # Public: Map the correct fields.
      #
      # Returns nothing.
      def map_model(model)
        self.question_id = model.decidim_question_id
        self.question = model.question

        self.choices = model.choices.map do |choice|
          AnswerChoiceForm.from_model(choice)
        end
      end

      def selected_choices
        choices.select(&:body)
      end

      def display_conditions_fulfilled?
        question.display_conditions.all? do |condition|
          answer = question.questionnaire.answers.find_by(question: condition.condition_question)
          condition.fulfilled?(answer)
        end
      end

      private

      def mandatory_body?
        question.mandatory_body? if display_conditions_fulfilled?
      end

      def mandatory_choices?
        question.mandatory_choices? if display_conditions_fulfilled?
      end

      def grouped_choices
        selected_choices.group_by(&:matrix_row_id).values
      end

      def max_choices
        if matrix?
          errors.add(:choices, :too_many) if grouped_choices.any? { |choices| choices.count > question.max_choices }
        elsif selected_choices.size > question.max_choices
          errors.add(:choices, :too_many)
        end
      end

      def min_choices
        errors.add(:choices, :missing) if grouped_choices.count != question.matrix_rows.count
      end

      def all_choices
        errors.add(:choices, :missing) if selected_choices.size != question.number_of_options
      end

      def mandatory_label
        "*"
      end

      def max_choices_label
        I18n.t("questionnaires.question.max_choices", scope: "decidim.forms", n: question.max_choices)
      end
    end
  end
end
