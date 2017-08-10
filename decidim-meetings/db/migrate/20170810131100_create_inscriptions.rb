# frozen_string_literal: true

class CreateInscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_meetings_inscriptions do |t|
      t.references :decidim_user, null: false, index: true
      t.references :decidim_meeting, null: false, index: true

      t.timestamps
    end

    add_index :decidim_meetings_inscriptions, [:decidim_user_id, :decidim_meeting_id], unique: true, name: "decidim_meetings_inscriptions_user_meeting_unique"
  end
end
