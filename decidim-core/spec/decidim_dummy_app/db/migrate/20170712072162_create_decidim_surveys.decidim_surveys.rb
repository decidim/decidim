# This migration comes from decidim_surveys (originally 20170511092231)
# frozen_string_literal: true

class CreateDecidimSurveys < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_surveys_surveys do |t|
      t.jsonb :title
      t.jsonb :description
      t.jsonb :tos
      t.references :decidim_feature, index: true
      t.datetime :published_at

      t.timestamps
    end
  end
end
