# frozen_string_literal: true

class MergeMinutesWithClosingReportInMeetingsTable < ActiveRecord::Migration[6.0]
  class Meeting < ApplicationRecord
    self.table_name = "decidim_meetings_meetings"
  end

  def up
    Meeting.find_each do |meeting|
      check_close_data_presence(meeting)
      check_closing_visibility(meeting)
      merge_closing_report(meeting)

      meeting.save!
    end

    rename_column :decidim_meetings_meetings, :minutes_visible, :closing_visible
    remove_column :decidim_meetings_meetings, :minutes_description
  end

  def down
    add_column :decidim_meetings_meetings, :minutes_description, :jsonb
    rename_column :decidim_meetings_meetings, :closing_visible, :minutes_visible
  end
end

private

# Ensures close meeting if minutes_data exists
def check_close_data_presence(meeting)
  return if meeting.closed_at.present? || !minutes_data?(meeting)

  meeting.closed_at = Time.current
end

# If meeting is closed and minutes data is blank the closing
# should remain visible unless it has already been defined
def check_closing_visibility(meeting)
  return unless meeting.minutes_visible.nil?
  return if minutes_data?(meeting) || meeting.closed_at.blank?

  meeting.minutes_visible = true
end

# Ignore minutes_description if already exists a closing report or
# minutes_description is blank
def merge_closing_report(meeting)
  return if meeting.closing_report.is_a?(Hash) && meeting.closing_report.values.any?(&:present?)
  return unless meeting.minutes_description.is_a?(Hash) && meeting.minutes_description.values.any?(&:present?)

  meeting.closing_report = meeting.minutes_description
end

def minutes_data?(meeting)
  [meeting.video_url, meeting.audio_url].any?(&:present?) ||
    (meeting.minutes_description.is_a?(Hash) && meeting.minutes_description.values.any?(&:present?))
end
