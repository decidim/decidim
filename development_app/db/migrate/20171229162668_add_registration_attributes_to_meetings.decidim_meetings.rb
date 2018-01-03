# This migration comes from decidim_meetings (originally 20170810120836)
# frozen_string_literal: true

class AddRegistrationAttributesToMeetings < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_meetings_meetings, :registrations_enabled, :boolean, null: false, default: false
    add_column :decidim_meetings_meetings, :available_slots, :integer, null: false, default: 0
    add_column :decidim_meetings_meetings, :registration_terms, :jsonb
  end
end
