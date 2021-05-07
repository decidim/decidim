# frozen_string_literal: true

class MergeMeetingsMinutesIntoMeetingsTable < ActiveRecord::Migration[6.0]
  def up
    add_column :decidim_meetings_meetings, :minutes_description, :jsonb
    add_column :decidim_meetings_meetings, :video_url, :string
    add_column :decidim_meetings_meetings, :audio_url, :string
    add_column :decidim_meetings_meetings, :minutes_visible, :boolean

    minutes_class.find_each do |minutes|
      minutes.meeting.update!(
        minutes_description: minutes.description,
        video_url: minutes.video_url,
        audio_url: minutes.audio_url,
        minutes_visible: minutes.visible
      )
    end
  end

  def down
    Decidim::Meetings::Meeting.find_each do |meeting|
      next if meeting.video_url.blank? && meeting.audio_url.blank?

      minutes_class.find_or_create_by!(
        decidim_meeting_id: meeting.id,
        description: meeting.minutes_description,
        video_url: meeting.video_url,
        audio_url: meeting.audio_url,
        visible: meeting.minutes_visible
      )
    end

    remove_column :decidim_meetings_meetings, :minutes_description
    remove_column :decidim_meetings_meetings, :video_url
    remove_column :decidim_meetings_meetings, :audio_url
    remove_column :decidim_meetings_meetings, :minutes_visible
  end
end

private

def minutes_class
  Class.new(ApplicationRecord) do
    self.table_name = "decidim_meetings_minutes"
    def self.name
      "TmpMinutes"
    end

    belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
  end
end
