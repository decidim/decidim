# frozen_string_literal: true
module Decidim
  module Surveys
    # The data store for a SurveyQuestion in the Decidim::Surveys component.
    class SurveyQuestion < Surveys::ApplicationRecord
      belongs_to :survey, class_name: Survey, foreign_key: "decidim_survey_id"
    end
  end
end
