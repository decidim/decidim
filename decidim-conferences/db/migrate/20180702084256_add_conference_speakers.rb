# frozen_string_literal: true

class AddConferenceSpeakers < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_conference_speakers do |t|
      t.references :decidim_conference, index: true
      t.string :full_name
      t.jsonb :position
      t.jsonb :affiliation
      t.string :twitter_handle
      t.jsonb :short_bio
      t.string :personal_url
      t.string :avatar
      t.references :decidim_user, index: { name: "index_decidim_conference_speaker_on_decidim_user_id" }

      t.timestamps
    end
  end
end
