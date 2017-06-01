# frozen_string_literal: true

module Decidim
  module Surveys
    # The data store for a Survey in the Decidim::Surveys component.
    class Survey < Surveys::ApplicationRecord
      include Decidim::HasFeature

      feature_manifest_name "surveys"

      has_many :questions, -> { order(:position) }, class_name: SurveyQuestion, foreign_key: "decidim_survey_id"
      has_many :answers, class_name: SurveyAnswer, foreign_key: "decidim_survey_id"

      # Public: returns whether the survey questions can be modified or not.
      def questions_editable?
        answers.empty?
      end

      # Public: returns whether the survey is answered by the user or not.
      def answered_by?(user)
        answers.where(user: user).count == questions.length
      end
    end
  end
end
