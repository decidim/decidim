# frozen_string_literal: true

class MoveMeetingServicesToOwnModel < ActiveRecord::Migration[5.2]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
  end

  class Service < ApplicationRecord
    self.table_name = :decidim_meetings_services
  end

  def change
    create_table :decidim_meetings_services do |t|
      t.jsonb :title
      t.jsonb :description
      t.bigint :decidim_meeting_id, null: false, index: true

      t.timestamps
    end

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
  end
end
