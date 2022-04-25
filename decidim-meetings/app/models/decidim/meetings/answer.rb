# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for an Answer in the Decidim::Meetings
    class Answer < Meetings::ApplicationRecord
      include Decidim::DownloadYourData

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id", optional: true
      belongs_to :questionnaire, class_name: "Decidim::Meetings::Questionnaire", foreign_key: "decidim_questionnaire_id"
      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"

      has_many :choices,
               class_name: "AnswerChoice",
               foreign_key: "decidim_answer_id",
               dependent: :destroy,
               inverse_of: :answer

      validate :user_questionnaire_same_organization
      validate :question_belongs_to_questionnaire

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Meetings::DownloadYourDataUserAnswersSerializer
      end

      def organization
        user.organization if user.present?
        questionnaire&.questionnaire_for.try(:organization)
      end

      private

      def user_questionnaire_same_organization
        return if user.nil? || user&.organization == questionnaire.questionnaire_for&.organization

        errors.add(:user, :invalid)
      end

      def question_belongs_to_questionnaire
        errors.add(:questionnaire, :invalid) if question&.questionnaire != questionnaire
      end
    end
  end
end
