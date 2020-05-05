# frozen_string_literal: true

module Decidim
  module Forms
    # This models represents a questionnaire submission by a user.
    class QuestionnaireAnswer < Forms::ApplicationRecord
      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id", optional: true
      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_questionnaire_id"

      validate :user_questionnaire_same_organization

      private

      def user_questionnaire_same_organization
        return if user.nil? || user&.organization == questionnaire.questionnaire_for&.organization

        errors.add(:user, :invalid)
      end
    end
  end
end
