# frozen_string_literal: true

class AddConferenceRegistrationsCounterCacheToDecidimConferencesRegistrationTypes < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_conferences_registration_types, :conference_registrations_count, :integer, default: 0, null: false
  end
end
