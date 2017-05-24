# frozen_string_literal: true
module Decidim
  module Surveys
    # The data store for a SurveyAnswer in the Decidim::Surveys component.
    class SurveyAnswer < Surveys::ApplicationRecord
      belongs_to :user, class_name: Decidim::User, foreign_key: "decidim_user_id"
      belongs_to :survey, class_name: Survey, foreign_key: "decidim_survey_id"
      belongs_to :question, class_name: SurveyQuestion, foreign_key: "decidim_survey_question_id"

      validates :body, presence: true, if: -> { question.mandatory? }
      validate :user_survey_same_organization
      validate :question_belongs_to_survey

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
