# This migration comes from decidim_surveys (originally 20170515144119)
# frozen_string_literal: true

class CreateDecidimSurveyAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_surveys_survey_answers do |t|
      t.jsonb :body, default: []
      t.references :decidim_user, index: true
      t.references :decidim_survey, index: true
      t.references :decidim_survey_question, index: { name: "index_decidim_surveys_answers_question_id" }

      t.timestamps
    end
  end
end
