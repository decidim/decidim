# frozen_string_literal: true

module Decidim
  module Surveys
    # This class holds a Form to update survey unswers from Decidim's public page
    class SurveyAnswerForm < Decidim::Form
      attribute :question_id, String
      attribute :body, String

      validates :body, presence: true, if: -> { question.mandatory? }
      validate :body_not_blank, if: -> { question.mandatory? }

      def question
        @question ||= survey.questions.find(question_id)
      end

      # Public: Map the correct fields.
      #
      # Returns nothing.
      def map_model(model)
        self.question_id = model.id
      end

      private

      def survey
        @survey ||= Survey.where(feature: current_feature).first
      end

      def body_not_blank
        return if body.nil?
        errors.add("body", :blank) if body.all?(&:blank?)
      end
    end
  end
end
