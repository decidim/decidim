# frozen_string_literal: true
module Decidim
  module Surveys
    # This class holds a Form to update survey unswers from Decidim's public page
    class SurveyAnswerForm < Decidim::Form
      attribute :question
      attribute :survey_question_id, String
      attribute :body, String
    end
  end
end
