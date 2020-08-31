# frozen_string_literal: true

class RemoveSurveyQuestions < ActiveRecord::Migration[5.2]
  def change
    drop_table :decidim_surveys_survey_questions, if_exists: true
  end
end
