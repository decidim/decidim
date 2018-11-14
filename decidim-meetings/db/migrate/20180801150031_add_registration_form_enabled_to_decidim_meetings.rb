# frozen_string_literal: true

class AddRegistrationFormEnabledToDecidimMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :registration_form_enabled, :boolean, default: false
  end
end
