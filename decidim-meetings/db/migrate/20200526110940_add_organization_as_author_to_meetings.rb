# frozen_string_literal: true

class AddOrganizationAsAuthorToMeetings < ActiveRecord::Migration[5.2]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
    include Decidim::HasComponent
  end

  def change
    add_column :decidim_meetings_meetings, :organizer_type, :string

    Meeting.reset_column_information
    Meeting.find_each do |meeting|
      if meeting.organizer_id.present?
        meeting.organizer_type = "Decidim::UserBaseEntity"
      else
        meeting.organizer_id = meeting.organization.id
        meeting.organizer_type = "Decidim::Organization"
      end
      meeting.save!
    end

    add_index :decidim_meetings_meetings,
              [:organizer_id, :organizer_type],
              name: "index_decidim_meetings_meetings_on_organizer"
    change_column_null :decidim_meetings_meetings, :organizer_id, false
    change_column_null :decidim_meetings_meetings, :organizer_type, false
  end
end
