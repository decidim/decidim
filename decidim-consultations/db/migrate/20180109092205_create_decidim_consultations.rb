# frozen_string_literal: true

class CreateDecidimConsultations < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_consultations do |t|
      t.string :slug, null: false
      t.integer :decidim_organization_id,
                foreign_key: true,
                index: {
                  name: "index_decidim_consultations_on_decidim_organization_id"
                }

      t.index [:decidim_organization_id, :slug],
              name: "index_unique_consultation_slug_and_organization",
              unique: true

      t.jsonb :title, null: false
      t.jsonb :subtitle, null: false
      t.jsonb :description, null: false

      # Text search indexes for consultations.
      t.index :title, name: "decidim_consultations_title_search"
      t.index :subtitle, name: "decidim_consultations_subtitle_search"
      t.index :description, name: "decidim_consultations_description_search"

      t.string :banner_image
      t.string :introductory_video_url
      t.date :start_voting_date, null: false
      t.integer :decidim_highlighted_scope_id, index: true

      # Publicable
      t.datetime :published_at, index: true

      t.timestamps
    end
  end
end
