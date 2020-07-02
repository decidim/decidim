# frozen_string_literal: true

class MoveMeetingServicesToOwnModel < ActiveRecord::Migration[5.2]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
  end

  class Service < ApplicationRecord
    self.table_name = :decidim_meetings_services
  end

  def change
    Meeting.reset_column_information
    Service.reset_column_information

    Meeting.find_each do |meeting|
      meeting["services"].each do |service|
        Service.create!(
          decidim_meeting_id: meeting.id,
          title: service["title"],
          description: service["description"]
        )
      end
    end

    remove_column :decidim_meetings_meetings, :services

    Meeting.reset_column_information
    Service.reset_column_information
  end
end
