# frozen_string_literal: true

class AddConferenceMeetingRegistrationTypesCountToDecidimConferencesRegistrationTypes < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_conferences_registration_types, :conference_meeting_registration_types_count, :integer, default: 0, null: false
  end
end
