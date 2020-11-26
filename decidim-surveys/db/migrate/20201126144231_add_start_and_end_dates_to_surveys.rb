# frozen_string_literal: true

class AddStartAndEndDatesToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_surveys_surveys, :starts_at, :datetime
    add_column :decidim_surveys_surveys, :ends_at, :datetime
  end
end
