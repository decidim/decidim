# frozen_string_literal: true

class CreateDecidimElectionsElections < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_elections_elections do |t|
      t.integer :decidim_component_id
      t.jsonb :title
      t.jsonb :description
      t.jsonb :announcement
      t.timestamp :start_at, index: true
      t.timestamp :end_at, index: true
      t.string :results_availability, default: "after_end", null: false
      t.integer :census_type, default: 0, null: false
      t.timestamp :published_at, index: true
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
