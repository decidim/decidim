# frozen_string_literal: true

class ChangeTypesAndRegistrationTypesOnMeetings < ActiveRecord::Migration[6.1]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings

    TYPE_OF_MEETING = { in_person: 0, online: 10, hybrid: 20 }.freeze
    REGISTRATION_TYPES = { registration_disabled: 0, on_this_platform: 10, on_different_platform: 20 }.freeze
  end

  def up
    rename_column :decidim_meetings_meetings, :type_of_meeting, :old_type_of_meeting
    rename_column :decidim_meetings_meetings, :registration_type, :old_registration_type
    add_column :decidim_meetings_meetings, :type_of_meeting, :integer, default: 0, null: false
    add_column :decidim_meetings_meetings, :registration_type, :integer, default: 0, null: false

    Meeting.reset_column_information

    Meeting::TYPE_OF_MEETING.each_pair do |status, index|
      Meeting.where(old_type_of_meeting: status).update_all(type_of_meeting: index) # rubocop:disable Rails/SkipsModelValidations
    end
    Meeting::REGISTRATION_TYPES.each_pair do |status, index|
      Meeting.where(old_registration_type: status).update_all(registration_type: index) # rubocop:disable Rails/SkipsModelValidations
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

    Meeting::TYPE_OF_MEETING.each_pair do |status, index|
      Meeting.where(old_type_of_meeting: index).update_all(type_of_meeting: status) # rubocop:disable Rails/SkipsModelValidations
    end
    Meeting::REGISTRATION_TYPES.each_pair do |status, index|
      Meeting.where(old_registration_type: index).update_all(registration_type: status) # rubocop:disable Rails/SkipsModelValidations
    end

    remove_column :decidim_meetings_meetings, :old_type_of_meeting
    remove_column :decidim_meetings_meetings, :old_registration_type
  end
end
