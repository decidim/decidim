# This migration comes from decidim_surveys (originally 20170522075938)
# frozen_string_literal: true

class AddMandatoryToSurveysQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_surveys_survey_questions, :mandatory, :boolean
  end
end
