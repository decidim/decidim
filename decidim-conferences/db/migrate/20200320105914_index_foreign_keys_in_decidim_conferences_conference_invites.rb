# frozen_string_literal: true

class IndexForeignKeysInDecidimConferencesConferenceInvites < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_conferences_conference_invites, :decidim_conference_registration_type_id, name: "ixd_conferences_on_registration_type_id"
  end
end
