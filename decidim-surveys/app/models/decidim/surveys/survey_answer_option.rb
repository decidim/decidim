# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveyAnswerOption < Surveys::ApplicationRecord
      belongs_to :question, class_name: "SurveyQuestion", foreign_key: "decidim_survey_question_id"
    end
  end
end
