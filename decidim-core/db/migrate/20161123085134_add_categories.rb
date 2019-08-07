# frozen_string_literal: true

class AddCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_categories do |t|
      t.jsonb :name, null: false
      t.jsonb :description, null: false
      t.integer :parent_id, index: true
      t.integer :decidim_participatory_process_id, index: true
    end
  end
end
