# frozen_string_literal: true

class AddRegistrationTypeToConferenceInvite < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_conferences_conference_invites, :decidim_conference_registration_type_id,
               :integer, index: { name: "idx_conference_invite_to_registration_type_id" }
  end
end
