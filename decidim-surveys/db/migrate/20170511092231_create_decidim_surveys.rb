# frozen_string_literal: true

class CreateDecidimSurveys < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_surveys_surveys do |t|
      t.references :decidim_feature, index: true

      t.timestamps
    end
  end
end
