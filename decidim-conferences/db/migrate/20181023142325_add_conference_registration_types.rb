# frozen_string_literal: true

class AddConferenceRegistrationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_conferences_registration_types do |t|
      t.references :decidim_conference, index: { name: "idx_registration_types_on_decidim_conference_id" }
      t.jsonb :title, null: false
      t.jsonb :description, null: false
      t.decimal :price, null: false, default: 0, precision: 8, scale: 2
      t.integer :weight, null: false, default: 0
      t.datetime :published_at, index: true

      t.timestamps
    end

    create_table :decidim_conferences_conference_meeting_registration_types do |t|
      t.belongs_to :registration_type, null: false, index: { name: "index_meetings_on_decidim_registration_type_id" }
      t.belongs_to :conference_meeting, null: false, index: { name: "index_registrations_on_decidim_conference_meeting_id" }
    end
  end
end
