# frozen_string_literal: true

module Decidim
  module Surveys
    # This class holds a Form to update survey unswers from Decidim's public page
    class SurveyAnswerForm < Decidim::Form
      include Decidim::TranslationsHelper

      attribute :question_id, String
      attribute :body, String
      attribute :choices, Array[SurveyAnswerChoiceForm]

      validates :body, presence: true, if: :mandatory_body?
      validates :selected_choices, presence: true, if: :mandatory_choices?

      validate :max_choices, if: -> { question.max_choices }
      validate :all_choices, if: -> { question.question_type == "sorting" }

      delegate :mandatory_body?, :mandatory_choices?, to: :question

      attr_writer :question

      def question
        @question ||= Decidim::Surveys::SurveyQuestion.find(question_id)
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
        self.question_id = model.decidim_survey_question_id
        self.question = model.question

        self.choices = model.choices.map do |choice|
          SurveyAnswerChoiceForm.from_model(choice)
        end
      end

      def selected_choices
        choices.select(&:body)
      end

      private

      def max_choices
        errors.add(:choices, :too_many) if selected_choices.size > question.max_choices
      end

      def all_choices
        errors.add(:choices, :missing) if selected_choices.size != question.number_of_options
      end

      def mandatory_label
        "*"
      end

      def max_choices_label
        I18n.t("surveys.question.max_choices", scope: "decidim.surveys", n: question.max_choices)
      end
    end
  end
end
