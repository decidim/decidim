# frozen_string_literal: true

class MergeMinutesWithClosingReportInMeetingsTable < ActiveRecord::Migration[6.0]
  def up
    Decidim::Meetings::Meeting.find_each do |meeting|
      check_close_data_presence(meeting)
      check_closing_visibility(meeting)
      merge_closing_report(meeting)
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
  return if meeting.closed? || !minutes_data?(meeting)

  # rubocop:disable Rails/SkipsModelValidations
  meeting.update_attribute(:closed_at, Time.current)
  # rubocop:enable Rails/SkipsModelValidations
end

# If meeting is closed and minutes data is blank the closing
# should remain visible unless it has already been defined
def check_closing_visibility(meeting)
  return unless meeting.minutes_visible.nil?
  return if minutes_data?(meeting) || !meeting.closed?

  # rubocop:disable Rails/SkipsModelValidations
  meeting.update_attribute(:minutes_visible, true)
  # rubocop:enable Rails/SkipsModelValidations
end

# Ignore minutes_description if already exists a closing report or
# minutes_description is blank
def merge_closing_report(meeting)
  return if meeting.closing_report.is_a?(Hash) && meeting.closing_report.values.any?(&:present?)
  return unless meeting.minutes_description.is_a?(Hash) && meeting.minutes_description.values.any?(&:present?)

  # rubocop:disable Rails/SkipsModelValidations
  meeting.update_attribute(:closing_report, meeting.minutes_description)
  # rubocop:enable Rails/SkipsModelValidations
end

def minutes_data?(meeting)
  [meeting.video_url, meeting.audio_url].any?(&:present?) ||
    meeting.minutes_description.is_a?(Hash) && meeting.minutes_description.values.any?(&:present?)
end
