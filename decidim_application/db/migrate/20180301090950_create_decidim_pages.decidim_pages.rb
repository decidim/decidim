# This migration comes from decidim_pages (originally 20161116121353)
# frozen_string_literal: true

class CreateDecidimPages < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_pages_pages do |t|
      t.jsonb :title
      t.jsonb :body
      t.references :decidim_feature, index: true

      t.timestamps
    end
  end
end
