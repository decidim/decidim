# frozen_string_literal: true

class ChangeTypesAndRegistrationTypesOnMeetings < ActiveRecord::Migration[6.1]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings

    TYPE_OF_MEETING = %w(in_person online hybrid).freeze
    REGISTRATION_TYPES = %w(registration_disabled on_this_platform on_different_platform).freeze
  end

  def up
    rename_column :decidim_meetings_meetings, :type_of_meeting, :old_type_of_meeting
    rename_column :decidim_meetings_meetings, :registration_type, :old_registration_type
    add_column :decidim_meetings_meetings, :type_of_meeting, :integer, default: 0, null: false
    add_column :decidim_meetings_meetings, :registration_type, :integer, default: 0, null: false

    Meeting.reset_column_information

    Meeting.find_each do |meeting|
      meeting.update(type_of_meeting: Meeting::TYPE_OF_MEETING.index(meeting.old_type_of_meeting))
      meeting.update(registration_type: Meeting::REGISTRATION_TYPES.index(meeting.old_registration_type))
    end

    remove_column :decidim_meetings_meetings, :old_type_of_meeting
    remove_column :decidim_meetings_meetings, :old_registration_type
  end

  def down
    rename_column :decidim_meetings_meetings, :type_of_meeting, :old_type_of_meeting
    rename_column :decidim_meetings_meetings, :registration_type, :old_registration_type

    add_column :decidim_meetings_meetings, :type_of_meeting, :string, default: null
    add_column :decidim_meetings_meetings, :registration_type, :string, default: null

    Meeting.reset_column_information

    Meeting.find_each do |meeting|
      meeting.update(type_of_meeting: Meeting::TYPE_OF_MEETING[meeting.old_type_of_meeting])
      meeting.update(registration_type: Meeting::REGISTRATION_TYPES[meeting.old_registration_type])
    end

    remove_column :decidim_meetings_meetings, :old_type_of_meeting
    remove_column :decidim_meetings_meetings, :old_registration_type
  end
end
