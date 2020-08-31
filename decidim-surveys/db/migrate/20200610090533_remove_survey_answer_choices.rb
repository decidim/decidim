# frozen_string_literal: true

class RemoveSurveyAnswerChoices < ActiveRecord::Migration[5.2]
  def change
    drop_table :decidim_surveys_survey_answer_choices, if_exists: true
  end
end
