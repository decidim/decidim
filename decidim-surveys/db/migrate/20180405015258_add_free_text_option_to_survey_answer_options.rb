# frozen_string_literal: true

class AddFreeTextOptionToSurveyAnswerOptions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_surveys_survey_answer_options, :free_text_option, :boolean
  end
end
