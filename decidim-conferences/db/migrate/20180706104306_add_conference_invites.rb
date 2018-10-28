# frozen_string_literal: true

class AddConferenceInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_conferences_conference_invites do |t|
      t.references :decidim_user, null: false, index: true
      t.references :decidim_conference, null: false,
                                        index: { name: "idx_decidim_conferences_invites_on_conference_id" }
      t.datetime :sent_at
      t.datetime :accepted_at
      t.datetime :rejected_at

      t.timestamps
    end
  end
end
