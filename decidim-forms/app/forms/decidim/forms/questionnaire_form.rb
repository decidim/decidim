# frozen_string_literal: true

module Decidim
  module Forms
    # This class holds a Form to answer a questionnaire from Decidim's public page.
    class QuestionnaireForm < Decidim::Form
      mimic :survey # FIXME: remove

      attribute :survey_answers, Array[AnswerForm]

      attribute :tos_agreement, Boolean
      validates :tos_agreement, allow_nil: false, acceptance: true

      # Private: Create the answers from the survey questions
      #
      # Returns nothing.
      def map_model(model)
        self.survey_answers = model.questions.map do |question|
          AnswerForm.from_model(Decidim::Surveys::SurveyAnswer.new(question: question))
        end
      end
    end
  end
end
