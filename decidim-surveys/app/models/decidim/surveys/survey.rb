# frozen_string_literal: true
module Decidim
  module Surveys
    # The data store for a Survey in the Decidim::Surveys component.
    class Survey < Surveys::ApplicationRecord
      include Decidim::HasFeature

      feature_manifest_name "surveys"

      has_many :questions, class_name: SurveyQuestion, foreign_key: "decidim_survey_id"

      # Public: returns wether the survey is published or not.
      def published?
        published_at.present?
      end

      # Public: returns wether the survey is answered by the user or not.
      def answered_by?(user)
        SurveyAnswer.where(user: user, survey: self, question: questions).count == questions.length
      end
    end
  end
end
