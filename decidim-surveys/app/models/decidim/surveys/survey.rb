# frozen_string_literal: true

module Decidim
  module Surveys
    # The data store for a Survey in the Decidim::Surveys component.
    class Survey < Surveys::ApplicationRecord
      include Decidim::HasFeature

      feature_manifest_name "surveys"

      has_many :questions, -> { order(:position) }, class_name: SurveyQuestion, foreign_key: "decidim_survey_id"

      validate :questions_before_publishing?

      # Public: returns wether the survey is published or not.
      def published?
        published_at.present?
      end

      # Public: returns wether the survey is answered by the user or not.
      def answered_by?(user)
        SurveyAnswer.where(user: user, survey: self, question: questions).count == questions.length
      end

      private

      def questions_before_publishing?
        errors.add(:published_at, :invalid) if published? && questions.empty?
      end
    end
  end
end
