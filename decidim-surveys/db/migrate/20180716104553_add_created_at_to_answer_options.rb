# frozen_string_literal: true

class AddCreatedAtToAnswerOptions < ActiveRecord::Migration[5.2]
  def change
    change_table :decidim_surveys_survey_answer_options do |t|
      t.datetime :created_at
    end

    execute "UPDATE decidim_surveys_survey_answer_options SET created_at='#{Time.zone.now.to_s(:db)}'"

    change_column_null :decidim_surveys_survey_answer_options, :created_at, false
  end
end
