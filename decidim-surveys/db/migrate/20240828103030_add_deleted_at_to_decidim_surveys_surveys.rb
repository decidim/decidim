# frozen_string_literal: true

class AddDeletedAtToDecidimSurveysSurveys < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_surveys_surveys, :deleted_at, :datetime
    add_index :decidim_surveys_surveys, :deleted_at
  end
end
