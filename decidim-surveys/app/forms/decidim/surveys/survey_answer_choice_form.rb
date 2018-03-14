# frozen_string_literal: true

module Decidim
  module Surveys
    # This class holds a Form to update survey question answer options
    class SurveyAnswerChoiceForm < Decidim::Form
      attribute :body, String
      attribute :custom_body, String
      attribute :decidim_survey_answer_option_id, Integer

      validates :decidim_survey_answer_option_id, presence: true
    end
  end
end
