# frozen_string_literal: true

class CreateDecidimMeetingsInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_meetings_invites do |t|
      t.references :decidim_user, null: false, index: true
      t.references :decidim_meeting, null: false, index: true
      t.datetime :sent_at
      t.datetime :accepted_at
      t.datetime :rejected_at

      t.timestamps
    end
  end
end
