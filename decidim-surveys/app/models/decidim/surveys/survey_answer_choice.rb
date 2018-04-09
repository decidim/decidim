# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveyAnswerChoice < Surveys::ApplicationRecord
      belongs_to :answer,
                 class_name: "SurveyAnswer",
                 foreign_key: "decidim_survey_answer_id"

      belongs_to :answer_option,
                 class_name: "SurveyAnswerOption",
                 foreign_key: "decidim_survey_answer_option_id"
    end
  end
end
