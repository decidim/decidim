# frozen_string_literal: true

module Decidim
  module Surveys
    # The data store for a SurveyAnswer in the Decidim::Surveys component.
    class SurveyAnswer < Surveys::ApplicationRecord
      include Decidim::DataPortability

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"
      belongs_to :survey, class_name: "Survey", foreign_key: "decidim_survey_id"
      belongs_to :question, class_name: "SurveyQuestion", foreign_key: "decidim_survey_question_id"

      has_many :choices,
               class_name: "SurveyAnswerChoice",
               foreign_key: "decidim_survey_answer_id",
               dependent: :destroy,
               inverse_of: :answer

      validates :body, presence: true, if: -> { question.mandatory_body? }
      validates :choices, presence: true, if: -> { question.mandatory_choices? }

      validate :user_survey_same_organization
      validate :question_belongs_to_survey

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Surveys::DataPortabilitySurveyUserAnswersSerializer
      end

      private

      def user_survey_same_organization
        return if user&.organization == survey&.organization
        errors.add(:user, :invalid)
      end

      def question_belongs_to_survey
        errors.add(:survey, :invalid) if question&.survey != survey
      end
    end
  end
end
