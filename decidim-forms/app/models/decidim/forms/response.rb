# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for an Response in the Decidim::Forms
    class Response < Forms::ApplicationRecord
      include Decidim::DownloadYourData
      include Decidim::NewsletterParticipant
      include Decidim::HasAttachments

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id", optional: true
      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_questionnaire_id"
      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"

      has_many :choices,
               class_name: "ResponseChoice",
               foreign_key: "decidim_response_id",
               dependent: :destroy,
               inverse_of: :response

      validate :user_questionnaire_same_organization
      validate :question_belongs_to_questionnaire

      scope :not_separator, -> { joins(:question).where.not(decidim_forms_questions: { question_type: Decidim::Forms::Question::SEPARATOR_TYPE }) }
      scope :not_title_and_description, -> { joins(:question).where.not(decidim_forms_questions: { question_type: Decidim::Forms::Question::TITLE_AND_DESCRIPTION_TYPE }) }

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Forms::DownloadYourDataUserResponsesSerializer
      end

      def self.newsletter_participant_ids(component)
        surveys = Decidim::Surveys::Survey.joins(:component, :questionnaire).where(component:)
        questionnaires = Decidim::Forms::Questionnaire.includes(:questionnaire_for)
                                                      .where(questionnaire_for_type: Decidim::Surveys::Survey.name, questionnaire_for_id: surveys.pluck(:id))

        responses = Decidim::Forms::Response.joins(:questionnaire)
                                            .where(questionnaire: questionnaires)

        responses.pluck(:decidim_user_id).flatten.compact.uniq
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
