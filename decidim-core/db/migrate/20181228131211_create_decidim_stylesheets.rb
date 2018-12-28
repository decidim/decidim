# frozen_string_literal: true

class CreateDecidimStylesheets < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_stylesheets do |t|
      t.string :primary, limit: 6, default: "ef604d"
      t.string :secundary, limit: 6, default: "599aa6"
      t.string :success, limit: 6, default: "57d685"
      t.string :warning, limit: 6, default: "ffae00"
      t.string :alert, limit: 6, default: "ec5840"
      t.references :decidim_organization, foreign_key: true, index: { name: "index_decidim_stylesheet_to_organization" }

      t.timestamps
    end
  end
end
