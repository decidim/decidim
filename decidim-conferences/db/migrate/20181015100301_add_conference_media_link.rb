# frozen_string_literal: true

class AddConferenceMediaLink < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_conferences_media_links do |t|
      t.references :decidim_conference, index: true
      t.jsonb :title, null: false
      t.string :link, null: false
      t.date :date
      t.integer :weight, null: false, default: 0

      t.timestamps
    end
  end
end
