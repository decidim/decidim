# frozen_string_literal: true

module Decidim
  module Forms
    # This class holds a Form to answer a questionnaire from Decidim's public page.
    class QuestionnaireForm < Decidim::Form
      attribute :answers, Array[AnswerForm]

      attribute :tos_agreement, Boolean
      validates :tos_agreement, allow_nil: false, acceptance: true

      # Private: Create the answers from the questionnaire questions
      #
      # Returns nothing.
      def map_model(model)
        self.answers = model.questions.map do |question|
          AnswerForm.from_model(Decidim::Forms::Answer.new(question: question))
        end
      end
    end
  end
end
