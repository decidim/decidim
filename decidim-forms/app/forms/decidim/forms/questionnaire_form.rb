# frozen_string_literal: true

module Decidim
  module Forms
    # This class holds a Form to answer a questionnaire from Decidim's public page.
    class QuestionnaireForm < Decidim::Form
      attribute :answers, Array[AnswerForm]
      attribute :user_group_id, Integer

      attribute :tos_agreement, Boolean

      validates :tos_agreement, allow_nil: false, acceptance: true
      validate :session_token_in_context

      # Private: Create the answers from the questionnaire questions
      #
      # Returns nothing.
      def map_model(model)
        self.answers = model.questions.map do |question|
          AnswerForm.from_model(Decidim::Forms::Answer.new(question: question))
        end
      end

      def session_token_in_context
        return if context&.session_token

        errors.add(:tos_agreement, I18n.t("activemodel.errors.models.questionnaire.request_invalid"))
      end
    end
  end
end
