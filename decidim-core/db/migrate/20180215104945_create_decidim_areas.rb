# frozen_string_literal: true

class CreateDecidimAreas < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_areas do |t|
      t.jsonb :name
      t.references :area_type, foreign_key: { to_table: :decidim_area_types }, index: true
      t.references :decidim_organization, foreign_key: true, index: true
      t.timestamps
    end
  end
end
