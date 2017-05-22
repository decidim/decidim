# frozen_string_literal: true
module Decidim
  module Surveys
    # This class holds a Form to update survey unswers from Decidim's public page
    class SurveyAnswerForm < Decidim::Form
      attribute :question_id, String
      attribute :body, String

      validates :body, presence: true, if: -> { question.mandatory? }

      def question
        @question ||= SurveyQuestion.find(question_id)
      end

      # Private: Map the correct fields.
      #
      # Returns nothing.
      def map_model(model)
        self.question_id = model.id
      end
    end
  end
end
