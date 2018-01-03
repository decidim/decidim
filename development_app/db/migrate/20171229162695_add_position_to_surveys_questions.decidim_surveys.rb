# This migration comes from decidim_surveys (originally 20170518085302)
# frozen_string_literal: true

class AddPositionToSurveysQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_surveys_survey_questions, :position, :integer, index: true
  end
end
