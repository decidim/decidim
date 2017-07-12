# This migration comes from decidim_surveys (originally 20170515090916)
# frozen_string_literal: true

class CreateDecidimSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_surveys_survey_questions do |t|
      t.jsonb :body
      t.references :decidim_survey, index: true

      t.timestamps
    end
  end
end
