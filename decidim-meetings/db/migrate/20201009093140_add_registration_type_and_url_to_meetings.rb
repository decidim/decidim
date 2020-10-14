# frozen_string_literal: true

class AddRegistrationTypeAndUrlToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :registration_type, :string, null: false, default: "registration_disabled"
    add_column :decidim_meetings_meetings, :registration_url, :string
  end
end
