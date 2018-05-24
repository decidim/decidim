# frozen_string_literal: true

module Decidim
  module Surveys
    # This class holds a Form to answer a surveys from Decidim's public page.
    class SurveyForm < Decidim::Form
      attribute :survey_answers, Array[SurveyAnswerForm]

      attribute :tos_agreement, Boolean
      validates :tos_agreement, allow_nil: false, acceptance: true

      # Private: Create the answers from the survey questions
      #
      # Returns nothing.
      def map_model(model)
        self.survey_answers = model.questions.map do |question|
          SurveyAnswerForm.from_model(SurveyAnswer.new(question: question))
        end
      end
    end
  end
end
