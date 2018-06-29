# frozen_string_literal: true

class AddConferences < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_conferences do |t|
      t.jsonb :title, null: false
      t.jsonb :slogan, null: false
      t.string :slug, null: false
      t.string :hashtag
      t.integer :decidim_organization_id,
                foreign_key: true,
                index: { name: "index_decidim_conferences_on_decidim_organization_id" }

      t.jsonb :short_description, null: false
      t.jsonb :description, null: false
      t.string :hero_image
      t.string :banner_image
      t.boolean :promoted, default: false
      t.datetime :published_at
      t.jsonb :objectives, null: false
      t.boolean :show_statistics, default: false
      t.datetime :start_date
      t.datetime :end_date

      t.index [:decidim_organization_id, :slug],
              name: "index_unique_conference_slug_and_organization",
              unique: true

      t.timestamps
    end
  end
end
