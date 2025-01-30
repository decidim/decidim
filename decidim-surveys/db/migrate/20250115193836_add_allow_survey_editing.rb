# frozen_string_literal: true

class AddAllowSurveyEditing < ActiveRecord::Migration[7.0]
  def up
    add_column :decidim_surveys_surveys, :allow_editing_answers, :boolean
  end
end
