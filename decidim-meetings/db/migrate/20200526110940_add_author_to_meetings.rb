# frozen_string_literal: true

class AddAuthorToMeetings < ActiveRecord::Migration[5.2]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
    include Decidim::HasComponent
  end

  def change
    add_column :decidim_meetings_meetings, :decidim_author_type, :string
    add_column :decidim_meetings_meetings, :decidim_user_group_id, :integer

    Meeting.reset_column_information
    Meeting.find_each do |meeting|
      if meeting.organizer_id.present?
        meeting.decidim_author_id = meeting.organizer_id
        meeting.decidim_author_type = "Decidim::UserBaseEntity"
      else
        meeting.decidim_author_id = meeting.organization.id
        meeting.decidim_author_type = "Decidim::Organization"
      end
      meeting.save!
    end

    remove_column :decidim_meetings_meetings, :organizer_id
    add_index :decidim_meetings_meetings,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_meetings_meetings_on_author"
  end
end
