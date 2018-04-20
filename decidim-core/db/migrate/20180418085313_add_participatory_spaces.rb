# frozen_string_literal: true

class AddParticipatorySpaces < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_participatory_spaces do |t|
      t.integer :decidim_organization_id, null: false
      t.string :manifest_name, null: false
      t.datetime :activated_at
      t.datetime :published_at
    end
  end
end
