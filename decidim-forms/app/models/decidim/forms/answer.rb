# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for an Answer in the Decidim::Forms
    class Answer < Forms::ApplicationRecord
      include Decidim::DataPortability

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"
      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_questionnaire_id"
      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"

      has_many :choices,
               class_name: "AnswerChoice",
               foreign_key: "decidim_answer_id",
               dependent: :destroy,
               inverse_of: :answer

      validates :body, presence: true, if: -> { question.mandatory_body? }
      validates :choices, presence: true, if: -> { question.mandatory_choices? }

      validate :user_questionnaire_same_organization
      validate :question_belongs_to_questionnaire

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Forms::DataPortabilityUserAnswersSerializer
      end

      private

      def user_questionnaire_same_organization
        return if user&.organization == questionnaire.questionnaire_for&.organization
        errors.add(:user, :invalid)
      end

      def question_belongs_to_questionnaire
        errors.add(:questionnaire, :invalid) if question&.questionnaire != questionnaire
      end
    end
  end
end
