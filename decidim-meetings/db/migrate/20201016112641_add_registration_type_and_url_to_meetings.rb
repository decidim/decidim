# frozen_string_literal: true

class AddRegistrationTypeAndUrlToMeetings < ActiveRecord::Migration[5.2]
  class Meetings < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
    include Decidim::HasComponent
  end

  def change
    add_column :decidim_meetings_meetings, :registration_type, :string, null: false, default: "registration_disabled"
    add_column :decidim_meetings_meetings, :registration_url, :string

    Meetings.reset_column_information
    Meetings.find_each do |meeting|
      meeting.registration_type = "on_this_platform" if meeting.decidim_author_type == "Decidim::Organization"
      meeting.save!
    end
  end
end
