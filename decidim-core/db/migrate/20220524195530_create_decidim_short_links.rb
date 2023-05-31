# frozen_string_literal: true

class CreateDecidimShortLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_short_links do |t|
      t.references :decidim_organization, null: false, index: true
      t.references :target, polymorphic: true, null: false, index: true
      t.string :identifier, limit: 10, null: false
      t.string :mounted_engine_name, index: true
      t.string :route_name, index: true
      t.jsonb :params

      t.timestamps
    end

    add_index(
      :decidim_short_links,
      [:decidim_organization_id, :identifier],
      unique: true,
      name: "idx_decidim_short_links_organization_id_identifier"
    )
  end
end
