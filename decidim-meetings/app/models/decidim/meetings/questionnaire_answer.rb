# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a QuestionnaireAnswer in the Decidim::Meetings component.
    class QuestionnaireAnswer < Meetings::ApplicationRecord
      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"
      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_meetings_questionnaire_id"
      belongs_to :question, class_name: "QuestionnaireQuestion", foreign_key: "decidim_meetings_questionnaire_question_id"

      has_many :choices,
               class_name: "QuestionnaireAnswerChoice",
               foreign_key: "decidim_meetings_questionnaire_answer_id",
               dependent: :destroy,
               inverse_of: :answer

      validates :body, presence: true, if: -> { question.mandatory_body? }
      validates :choices, presence: true, if: -> { question.mandatory_choices? }

      validate :user_questionnaire_same_organization
      validate :question_belongs_to_questionnaire

      private

      def user_questionnaire_same_organization
        return if user&.organization == questionnaire&.organization
        errors.add(:user, :invalid)
      end

      def question_belongs_to_questionnaire
        errors.add(:questionnaire, :invalid) if question&.questionnaire != questionnaire
      end
    end
  end
end
