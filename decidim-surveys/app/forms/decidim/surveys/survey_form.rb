# frozen_string_literal: true
module Decidim
  module Surveys
    # This class holds a Form to answer a surveys from Decidim's public page.
    class SurveyForm < Decidim::Form
      attribute :answers, Array[SurveyAnswerForm]

      # Private: Create the answers from the survey questions
      #
      # Returns nothing.
      def map_model(model)
        self.answers = model.questions.map do |question|
          SurveyAnswerForm.from_params(question: question)
        end
      end
    end
  end
end
