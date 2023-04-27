# frozen_string_literal: true

class ChangeFieldsOnMeetings < ActiveRecord::Migration[6.1]
  def up
    rename_column :decidim_meetings_meetings, :type_of_meeting, :old_type_of_meeting
    rename_column :decidim_meetings_meetings, :registration_type, :old_registration_type
    add_column :decidim_meetings_meetings, :type_of_meeting, :integer, default: 0, null: false
    add_column :decidim_meetings_meetings, :registration_type, :integer, default: 0, null: false

    Decidim::Meetings::Meeting.reset_column_information

    Decidim::Meetings::Meeting.find_each do |meeting|
      meeting.update(type_of_meeting: Decidim::Meetings::Meeting::TYPE_OF_MEETING.index(meeting.old_type_of_meeting))
      meeting.update(registration_type: Decidim::Meetings::Meeting::REGISTRATION_TYPES.index(meeting.old_registration_type))
    end

    remove_column :decidim_meetings_meetings, :old_type_of_meeting
    remove_column :decidim_meetings_meetings, :old_registration_type

    Decidim::Meetings::Meeting.reset_column_information
  end

  def down
    rename_column :decidim_meetings_meetings, :type_of_meeting, :old_type_of_meeting
    rename_column :decidim_meetings_meetings, :registration_type, :old_registration_type

    add_column :decidim_meetings_meetings, :type_of_meeting, :string, default: null
    add_column :decidim_meetings_meetings, :registration_type, :string, default: null

    Decidim::Meetings::Meeting.reset_column_information

    Decidim::Meetings::Meeting.find_each do |meeting|
      meeting.update(type_of_meeting: Decidim::Meetings::Meeting::TYPE_OF_MEETING[meeting.old_type_of_meeting])
      meeting.update(registration_type: Decidim::Meetings::Meeting::REGISTRATION_TYPES[meeting.old_registration_type])
    end

    remove_column :decidim_meetings_meetings, :old_type_of_meeting
    remove_column :decidim_meetings_meetings, :old_registration_type

    Decidim::Meetings::Meeting.reset_column_information
  end
end
