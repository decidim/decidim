# frozen_string_literal: true

class AddRegistrationCustomContentToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :customize_registration_email, :boolean, default: false, null: false
    add_column :decidim_meetings_meetings, :registration_email_custom_content, :jsonb
  end
end
