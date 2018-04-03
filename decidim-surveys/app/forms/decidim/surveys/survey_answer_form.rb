# frozen_string_literal: true

module Decidim
  module Surveys
    # This class holds a Form to update survey unswers from Decidim's public page
    class SurveyAnswerForm < Decidim::Form
      include Decidim::TranslationsHelper

      attribute :question_id, String
      attribute :body, Array[String]

      validates :body, presence: true, if: -> { question.mandatory? }

      validate :body_not_blank, if: -> { question.mandatory? }
      validate :max_answers, if: -> { question.max_choices }

      def question
        @question ||= survey.questions.find(question_id)
      end

      def label
        base = "#{question.position + 1}. #{translated_attribute(question.body)}"
        base += " #{mandatory_label}" if question.mandatory?
        base += " (#{max_choices_label})" if question.max_choices
        base
      end

      # Public: Map the correct fields.
      #
      # Returns nothing.
      def map_model(model)
        self.question_id = model.decidim_survey_question_id
      end

      private

      def survey
        @survey ||= Survey.where(component: current_component).first
      end

      def body_not_blank
        errors.add("body", :blank) if body.all?(&:blank?)
      end

      def max_answers
        errors.add("body", :too_many_choices) if body.size > question.max_choices
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
