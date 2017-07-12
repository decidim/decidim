# This migration comes from decidim_results (originally 20170116104125)
# frozen_string_literal: true

class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_results_results do |t|
      t.jsonb :title
      t.jsonb :description
      t.jsonb :short_description
      t.references :decidim_feature, index: true
      t.references :decidim_scope, index: true
      t.references :decidim_category, index: true

      t.timestamps
    end
  end
end
